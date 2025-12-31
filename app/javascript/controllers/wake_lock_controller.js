import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox"]

  connect() {
    this.wakeLock = null
    this.handleVisibilityChange = this.handleVisibilityChange.bind(this)
    document.addEventListener('visibilitychange', this.handleVisibilityChange)
  }

  disconnect() {
    this.releaseWakeLock()
    document.removeEventListener('visibilitychange', this.handleVisibilityChange)
  }

  toggle() {
    if (this.checkboxTarget.checked) {
      this.requestWakeLock()
    } else {
      this.releaseWakeLock()
    }
  }

  async requestWakeLock() {
    try {
      this.wakeLock = await navigator.wakeLock.request('screen')
      console.log('Wake lock is active')
    } catch (err) {
      console.error(`${err.name}, ${err.message}`)
    }
  }

  releaseWakeLock() {
    if (this.wakeLock !== null) {
      this.wakeLock.release()
      this.wakeLock = null
    }
  }

  handleVisibilityChange() {
    if (document.visibilityState === 'visible' && this.checkboxTarget.checked) {
      this.requestWakeLock()
    }
  }
}
