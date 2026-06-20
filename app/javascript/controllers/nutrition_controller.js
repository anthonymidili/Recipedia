import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "content", "button", "buttonText", "spinner"]

  connect() {
    this.loaded = false
    this.loading = false
  }

  toggle() {
    if (this.loading) return

    if (!this.loaded) {
      this.fetchNutrition()
    } else {
      this.toggleVisibility()
    }
  }

  async fetchNutrition() {
    this.loading = true
    this.showSpinner()

    try {
      const url = this.element.dataset.nutritionUrl
      const response = await fetch(url, {
        headers: {
          "Accept": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content
        }
      })

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`)
      }

      const data = await response.json()
      this.renderNutritionLabel(data)
      this.loaded = true
      this.showContent()
    } catch (error) {
      console.error("Failed to fetch nutrition data:", error)
      this.renderError()
    } finally {
      this.loading = false
      this.hideSpinner()
    }
  }

  renderNutritionLabel(data) {
    if (data.error) {
      this.renderError(data.error)
      return
    }

    const fatTotal = this.formatNum(data.fat_total_g)
    const fatSaturated = this.formatNum(data.fat_saturated_g)
    const cholesterol = this.formatNum(data.cholesterol_mg)
    const sodium = this.formatNum(data.sodium_mg)
    const carbsTotal = this.formatNum(data.carbohydrates_total_g)
    const fiber = this.formatNum(data.fiber_g)
    const sugar = this.formatNum(data.sugar_g)
    const potassium = this.formatNum(data.potassium_mg)

    // Daily values based on a 2,000 calorie diet
    const dvFat = this.dailyValue(data.fat_total_g, 78)
    const dvSatFat = this.dailyValue(data.fat_saturated_g, 20)
    const dvCholesterol = this.dailyValue(data.cholesterol_mg, 300)
    const dvSodium = this.dailyValue(data.sodium_mg, 2300)
    const dvCarbs = this.dailyValue(data.carbohydrates_total_g, 275)
    const dvFiber = this.dailyValue(data.fiber_g, 28)
    const dvPotassium = this.dailyValue(data.potassium_mg, 4700)

    const itemCount = data.serving_count || 0

    this.contentTarget.innerHTML = `
      <div class="nutrition-label">
        <div class="nutrition-label__header">
          <h2 class="nutrition-label__title">Nutrition Facts</h2>
          <p class="nutrition-label__subtitle">Entire Recipe (${itemCount} ingredient${itemCount !== 1 ? 's' : ''} analyzed)</p>
        </div>
        <div class="nutrition-label__divider nutrition-label__divider--thick"></div>

        <div class="nutrition-label__divider nutrition-label__divider--thick"></div>

        <div class="nutrition-label__dv-header">
          <span>% Daily Value*</span>
        </div>
        <div class="nutrition-label__divider"></div>

        <div class="nutrition-label__row">
          <span><strong>Total Fat</strong> ${fatTotal}g</span>
          <span class="nutrition-label__dv"><strong>${dvFat}%</strong></span>
        </div>
        <div class="nutrition-label__divider"></div>

        <div class="nutrition-label__row nutrition-label__row--indented">
          <span>Saturated Fat ${fatSaturated}g</span>
          <span class="nutrition-label__dv"><strong>${dvSatFat}%</strong></span>
        </div>
        <div class="nutrition-label__divider"></div>

        <div class="nutrition-label__row">
          <span><strong>Cholesterol</strong> ${cholesterol}mg</span>
          <span class="nutrition-label__dv"><strong>${dvCholesterol}%</strong></span>
        </div>
        <div class="nutrition-label__divider"></div>

        <div class="nutrition-label__row">
          <span><strong>Sodium</strong> ${sodium}mg</span>
          <span class="nutrition-label__dv"><strong>${dvSodium}%</strong></span>
        </div>
        <div class="nutrition-label__divider"></div>

        <div class="nutrition-label__row">
          <span><strong>Total Carbohydrate</strong> ${carbsTotal}g</span>
          <span class="nutrition-label__dv"><strong>${dvCarbs}%</strong></span>
        </div>
        <div class="nutrition-label__divider"></div>

        <div class="nutrition-label__row nutrition-label__row--indented">
          <span>Dietary Fiber ${fiber}g</span>
          <span class="nutrition-label__dv"><strong>${dvFiber}%</strong></span>
        </div>
        <div class="nutrition-label__divider"></div>

        <div class="nutrition-label__row nutrition-label__row--indented">
          <span>Total Sugars ${sugar}g</span>
          <span class="nutrition-label__dv"></span>
        </div>
        <div class="nutrition-label__divider nutrition-label__divider--thick"></div>

        <div class="nutrition-label__row">
          <span>Potassium ${potassium}mg</span>
          <span class="nutrition-label__dv"><strong>${dvPotassium}%</strong></span>
        </div>
        <div class="nutrition-label__divider nutrition-label__divider--medium"></div>

        <p class="nutrition-label__footnote">
          * Percent Daily Values are based on a 2,000 calorie diet.
          Values are estimates based on ingredient analysis.
        </p>
      </div>
    `
  }

  renderError(message) {
    const errorMsg = message || "Unable to load nutrition data. Please check that the API key is configured."
    this.contentTarget.innerHTML = `
      <div class="nutrition-error">
        <i class="fas fa-exclamation-triangle"></i>
        <p>${errorMsg}</p>
      </div>
    `
    this.loaded = true
    this.showContent()
  }

  toggleVisibility() {
    const content = this.contentTarget
    if (content.classList.contains("nutrition-content--visible")) {
      content.classList.remove("nutrition-content--visible")
      this.buttonTextTarget.textContent = "Show Nutrition Facts"
    } else {
      content.classList.add("nutrition-content--visible")
      this.buttonTextTarget.textContent = "Hide Nutrition Facts"
    }
  }

  showContent() {
    this.contentTarget.classList.add("nutrition-content--visible")
    this.buttonTextTarget.textContent = "Hide Nutrition Facts"
  }

  showSpinner() {
    this.spinnerTarget.classList.remove("hidden")
    this.buttonTextTarget.textContent = "Loading..."
    this.buttonTarget.disabled = true
  }

  hideSpinner() {
    this.spinnerTarget.classList.add("hidden")
    this.buttonTarget.disabled = false
  }

  formatNum(value) {
    const num = parseFloat(value) || 0
    return num < 1 ? num.toFixed(1) : Math.round(num)
  }

  dailyValue(value, dailyRef) {
    return Math.round(((parseFloat(value) || 0) / dailyRef) * 100)
  }
}
