import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sentinel", "container"]
  static values = {
    nextPage: Number,
    search: String
  }

  connect() {
    this.loading = false
    this.observer = new IntersectionObserver(entries => {
      entries.forEach(entry => {
        if (entry.isIntersecting && this.nextPageValue && !this.loading) {
          this.loadMore()
        }
      })
    })
    this.observer.observe(this.sentinelTarget)
    // Show sentinel initially if there are more pages
    if (this.nextPageValue) {
      this.sentinelTarget.style.display = 'block'
    }
  }

  disconnect() {
    this.observer.disconnect()
  }

  async loadMore() {
    if (this.loading) return
    this.loading = true
    this.sentinelTarget.style.display = 'block'

    const url = new URL(window.location)
    url.searchParams.set('page', this.nextPageValue)
    url.searchParams.set('format', 'json')

    try {
      const response = await fetch(url)
      const data = await response.json()

      // Append to the container target if it exists, otherwise to the controller element
      const container = this.hasContainerTarget ? this.containerTarget : this.element
      container.insertAdjacentHTML('beforeend', data.html)

      // Update next page
      this.nextPageValue = data.next_page || 0
      
      // Remove sentinel when no more pages
      if (!this.nextPageValue) {
        this.sentinelTarget.remove()
      }
    } catch (error) {
      console.error('Error loading more recipes:', error)
      this.sentinelTarget.style.display = 'none'
    } finally {
      this.loading = false
    }
  }
}