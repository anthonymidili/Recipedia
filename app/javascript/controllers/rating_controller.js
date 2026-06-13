import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="rating"
export default class extends Controller {
  static targets = ["star"]
  static values = { submitUrl: String }

  connect() {
  }

  hover(event) {
    const score = event.currentTarget.dataset.score
    this.updateStars(score)
  }

  leave() {
    // Reset to the current active score (we can read it from a hidden input or active class)
    const activeScore = this.element.dataset.currentScore || 0
    this.updateStars(activeScore)
  }

  updateStars(score) {
    this.starTargets.forEach((star) => {
      if (star.dataset.score <= score) {
        star.classList.add('active-star')
        star.classList.remove('inactive-star')
      } else {
        star.classList.remove('active-star')
        star.classList.add('inactive-star')
      }
    })
  }
}
