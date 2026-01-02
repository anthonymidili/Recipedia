import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "status"]
  
  connect() {
    this.statusTimeout = null
    this.checkPermission()
    
    // Show Safari info if user is on Safari
    if (this.isSafari()) {
      const safariInfo = document.querySelector('.safari-info')
      if (safariInfo) {
        safariInfo.style.display = 'block'
      }
    }
  }

  async checkPermission() {
    if (!('serviceWorker' in navigator) || !('PushManager' in window)) {
      this.showStatus('Push notifications are not supported by your browser', 'error')
      this.disableButton()
      return
    }

    // Check Safari specific issues
    if (this.isSafari()) {
      if (!this.isSafariSupported()) {
        this.showStatus('Safari 16+ on macOS 13+ or iOS 16.4+ required. Try updating Safari.', 'error')
        this.disableButton()
        return
      }
    }

    const permission = Notification.permission
    if (permission === 'granted') {
      this.checkSubscription()
    } else if (permission === 'denied') {
      this.showStatus('Push notifications are blocked. Reset in browser settings.', 'error')
      this.disableButton()
    }
  }

  async checkSubscription() {
    try {
      const registration = await navigator.serviceWorker.ready
      const subscription = await registration.pushManager.getSubscription()
      
      if (subscription) {
        this.updateButtonState(true)
        this.showStatus('Push notifications enabled', 'success')
      } else {
        this.updateButtonState(false)
      }
    } catch (error) {
      console.error('Error checking subscription:', error)
    }
  }

  async toggle() {
    try {
      // Check if service worker is ready first
      let registration = await navigator.serviceWorker.getRegistration()
      
      if (!registration) {
        // Register the service worker first
        try {
          registration = await navigator.serviceWorker.register('/service-worker.js', {
            scope: '/'
          })
          await navigator.serviceWorker.ready
        } catch (e) {
          console.error('Service worker registration failed:', e)
          throw new Error(`Service worker registration failed: ${e.message}`)
        }
      }
      
      const subscription = await registration.pushManager.getSubscription()

      if (subscription) {
        await this.unsubscribe(subscription)
      } else {
        await this.subscribe(registration)
      }
    } catch (error) {
      console.error('Push notification error:', error)
      this.showStatus(`Error: ${error.message}`, 'error')
    }
  }

  async subscribe(registration) {
    try {
      // For Safari, show a friendlier message first
      if (this.isSafari()) {
        this.showStatus('Click "Allow" when Safari asks for permission...', 'info')
        await new Promise(resolve => setTimeout(resolve, 500))
      }

      // Request permission first
      const permission = await Notification.requestPermission()
      
      if (permission !== 'granted') {
        if (permission === 'denied') {
          this.showStatus('Permission denied. To enable: Safari → Settings → Websites → Notifications', 'error')
        } else {
          this.showStatus('Permission denied for notifications', 'error')
        }
        return
      }

      // Get VAPID public key from server
      const response = await fetch('/push_subscriptions/vapid_public_key')
      
      if (!response.ok) {
        throw new Error('Failed to fetch VAPID public key')
      }
      
      const data = await response.json()
      const vapidPublicKey = data.publicKey
      
      if (!vapidPublicKey) {
        console.error('VAPID public key is missing. Add web_push credentials.')
        throw new Error('Server configuration error: VAPID keys not configured')
      }

      if (!registration) {
        throw new Error('Service worker registration not available')
      }

      // Subscribe to push notifications
      const subscription = await registration.pushManager.subscribe({
        userVisibleOnly: true,
        applicationServerKey: this.urlBase64ToUint8Array(vapidPublicKey)
      })

      // Send subscription to server
      const subscriptionData = {
        endpoint: subscription.endpoint,
        keys: {
          p256dh: this.arrayBufferToBase64(subscription.getKey('p256dh')),
          auth: this.arrayBufferToBase64(subscription.getKey('auth'))
        }
      }

      const saveResponse = await fetch('/push_subscriptions', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: JSON.stringify({ subscription: subscriptionData })
      })

      if (saveResponse.ok) {
        this.updateButtonState(true)
        this.showStatus('Push notifications enabled!', 'success')
        
        // Show OS settings reminder
        setTimeout(() => {
          this.showOSSettingsReminder()
        }, 2000)
      } else {
        const errorData = await saveResponse.json()
        console.error('Server error saving subscription:', errorData)
        throw new Error(errorData.errors?.join(', ') || 'Failed to save subscription')
      }
    } catch (error) {
      console.error('Error subscribing to push notifications:', error)
      this.showStatus(`Failed to enable push notifications: ${error.message}`, 'error')
    }
  }

  async unsubscribe(subscription) {
    try {
      await subscription.unsubscribe()

      await fetch('/push_subscriptions/1', {
        method: 'DELETE',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: JSON.stringify({ endpoint: subscription.endpoint })
      })

      this.updateButtonState(false)
      this.showStatus('Push notifications disabled', 'info')
    } catch (error) {
      console.error('Error unsubscribing from push notifications:', error)
      this.showStatus('Failed to disable push notifications', 'error')
    }
  }

  updateButtonState(isSubscribed) {
    if (this.hasButtonTarget) {
      this.buttonTarget.textContent = isSubscribed ? 'Disable Push Notifications' : 'Enable Push Notifications'
      this.buttonTarget.classList.toggle('enabled', isSubscribed)
      this.buttonTarget.disabled = false
    }
  }

  disableButton() {
    if (this.hasButtonTarget) {
      this.buttonTarget.disabled = true
      this.buttonTarget.style.opacity = '0.5'
      this.buttonTarget.style.cursor = 'not-allowed'
    }
  }

  isSafari() {
    const ua = navigator.userAgent.toLowerCase()
    return ua.indexOf('safari') !== -1 && ua.indexOf('chrome') === -1
  }

  isSafariSupported() {
    // If push notifications are available, Safari supports them
    // This is more reliable than version checking
    if ('PushManager' in window && 'serviceWorker' in navigator) {
      return true
    }
    
    // Additional version checks for reference
    const ua = navigator.userAgent
    
    // Check macOS version
    if (ua.includes('Macintosh')) {
      const match = ua.match(/Mac OS X (\d+)[_.](\d+)/)
      if (match) {
        const major = parseInt(match[1])
        const minor = parseInt(match[2])
        console.log(`Detected macOS ${major}.${minor}`)
        // macOS 13.0+ (Ventura) has better support but 10.15+ might work
        return major >= 10 && minor >= 15
      }
    }
    
    // Check iOS version
    if (ua.includes('iPhone') || ua.includes('iPad')) {
      const match = ua.match(/OS (\d+)[_.](\d+)/)
      if (match) {
        const major = parseInt(match[1])
        const minor = parseInt(match[2])
        console.log(`Detected iOS ${major}.${minor}`)
        // iOS 16.4+ officially supports it
        return major > 16 || (major === 16 && minor >= 4)
      }
    }
    
    // If we can't detect version but APIs exist, allow it
    return true
  }

  
  showOSSettingsReminder() {
    const isMac = navigator.platform.toUpperCase().indexOf('MAC') >= 0
    const isChrome = !this.isSafari()
    
    if (isMac && isChrome) {
      this.showStatus(
        '💡 Not seeing notifications? Check: System Settings → Notifications → Google Chrome → Enable "Allow Notifications"',
        'info'
      )
    } else if (isMac) {
      this.showStatus(
        '💡 Not seeing notifications? Check: System Settings → Notifications → Safari → Enable "Allow Notifications"',
        'info'
      )
    }
  }

  testOSNotifications() {
    // Test if OS-level notifications are actually showing
    // Create a test notification and check if it displays
    setTimeout(() => {
      try {
        const notification = new Notification('Recipedia', {
          body: 'Push notifications are enabled! 🎉',
          tag: 'test-notification',
          requireInteraction: false
        })
        
        let notificationShown = false
        
        notification.onshow = () => {
          notificationShown = true
        }
        
        notification.onerror = (error) => {
          console.error('Notification error:', error)
          this.showOSPermissionWarning()
        }
        
        // Check after 3 seconds if notification was shown
        setTimeout(() => {
          notification.close()
          if (!notificationShown) {
            this.showOSPermissionWarning()
          }
        }, 3000)
      } catch (error) {
        console.error('Error testing notification:', error)
        this.showOSPermissionWarning()
      }
    }, 500)
  }
  
  showOSPermissionWarning() {
    const isMac = navigator.platform.toUpperCase().indexOf('MAC') >= 0
    const isChrome = !this.isSafari()
    
    if (isMac && isChrome) {
      this.showStatus(
        '⚠️ To see notifications: Open System Settings → Notifications → Google Chrome → Turn ON "Allow Notifications"',
        'warning'
      )
    } else if (isMac) {
      this.showStatus(
        '⚠️ To see notifications: Open System Settings → Notifications → Safari → Turn ON "Allow Notifications"',
        'warning'
      )
    } else {
      this.showStatus(
        '⚠️ Check your system notification settings to allow browser notifications',
        'warning'
      )
    }
  }

  showStatus(message, type, duration = null) {
    if (this.hasStatusTarget) {
      // Clear any existing timeout
      if (this.statusTimeout) {
        clearTimeout(this.statusTimeout)
        this.statusTimeout = null
      }
      
      this.statusTarget.textContent = message
      this.statusTarget.className = `status ${type}`
      this.statusTarget.style.display = 'block'
      
      // Info messages stay permanent, others auto-hide
      if (type !== 'info') {
        const timeout = duration || (type === 'warning' ? 10000 : 5000)
        
        this.statusTimeout = setTimeout(() => {
          this.statusTarget.style.display = 'none'
        }, timeout)
      }
    }
  }

  // Helper functions
  urlBase64ToUint8Array(base64String) {
    const padding = '='.repeat((4 - base64String.length % 4) % 4)
    const base64 = (base64String + padding)
      .replace(/\-/g, '+')
      .replace(/_/g, '/')

    const rawData = window.atob(base64)
    const outputArray = new Uint8Array(rawData.length)

    for (let i = 0; i < rawData.length; ++i) {
      outputArray[i] = rawData.charCodeAt(i)
    }
    return outputArray
  }

  arrayBufferToBase64(buffer) {
    let binary = ''
    const bytes = new Uint8Array(buffer)
    for (let i = 0; i < bytes.byteLength; i++) {
      binary += String.fromCharCode(bytes[i])
    }
    return window.btoa(binary)
  }
}
