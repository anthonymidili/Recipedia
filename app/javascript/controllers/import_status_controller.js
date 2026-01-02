import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    importId: Number,
    pollInterval: { type: Number, default: 2000 }
  }

  connect() {
    if (this.hasImportIdValue) {
      this.startPolling()
    }
  }

  disconnect() {
    this.stopPolling()
  }

  startPolling() {
    this.pollTimer = setInterval(() => {
      this.checkStatus()
    }, this.pollIntervalValue)
  }

  stopPolling() {
    if (this.pollTimer) {
      clearInterval(this.pollTimer)
      this.pollTimer = null
    }
  }

  async checkStatus() {
    try {
      const response = await fetch(`/recipes/import_status/${this.importIdValue}`)
      const data = await response.json()

      if (data.status === 'completed') {
        this.stopPolling()
        // Reload the page to show the imported data
        window.location.reload()
      } else if (data.status === 'failed') {
        this.stopPolling()
        this.showError(data.error_message)
      } else if (data.status === 'processing') {
        this.updateStatus('Processing recipe...')
      }
    } catch (error) {
      console.error('Error checking import status:', error)
    }
  }

  updateStatus(message) {
    const statusElement = this.element.querySelector('[data-import-status-target="message"]')
    if (statusElement) {
      statusElement.textContent = message
    }
  }

  showError(message) {
    const statusElement = this.element.querySelector('[data-import-status-target="message"]')
    if (statusElement) {
      statusElement.textContent = `Import failed: ${message}`
      statusElement.classList.add('text-red-600')
    }
  }
}
