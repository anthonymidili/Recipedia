// Service Worker for Push Notifications v2.0
self.addEventListener('push', function(event) {
  if (!event.data) {
    return;
  }

  try {
    const data = event.data.json();
    
    const title = data.title || 'Recipedia';
    const options = {
      body: data.body,
      icon: data.icon || '/favicon.svg',
      badge: data.badge || '/favicon.svg',
      data: data.data,
      actions: data.actions || [],
      tag: 'recipedia-notification',
      requireInteraction: false
    };
    
    event.waitUntil(
      self.registration.showNotification(title, options)
    );
  } catch (error) {
    console.error('[SW] Error processing push event:', error);
  }
});

self.addEventListener('notificationclick', function(event) {
  event.notification.close();

  if (event.action === 'close') {
    return;
  }

  // Default action or 'view' action
  const urlToOpen = event.notification.data?.url || '/notifications';

  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then(function(clientList) {
      // Check if there's already a window open with this URL
      for (let i = 0; i < clientList.length; i++) {
        const client = clientList[i];
        if (client.url === urlToOpen && 'focus' in client) {
          return client.focus();
        }
      }
      // If no window is open, open a new one
      if (clients.openWindow) {
        return clients.openWindow(urlToOpen);
      }
    })
  );
});

self.addEventListener('pushsubscriptionchange', function(event) {
  console.log('[SW] Push subscription changed');
  
  const subscribeOptions = event.oldSubscription?.options || {
    userVisibleOnly: true,
    applicationServerKey: null // Will need to fetch from server
  };
  
  event.waitUntil(
    self.registration.pushManager.subscribe(subscribeOptions)
      .then(function(subscription) {
        console.log('[SW] Resubscribed successfully');
        // Send the new subscription to the server
        return fetch('/push_subscriptions', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            subscription: {
              endpoint: subscription.endpoint,
              keys: {
                p256dh: arrayBufferToBase64(subscription.getKey('p256dh')),
                auth: arrayBufferToBase64(subscription.getKey('auth'))
              }
            }
          })
        });
      })
  );
});

function arrayBufferToBase64(buffer) {
  let binary = '';
  const bytes = new Uint8Array(buffer);
  for (let i = 0; i < bytes.byteLength; i++) {
    binary += String.fromCharCode(bytes[i]);
  }
  return btoa(binary);
}
