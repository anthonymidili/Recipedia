import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list", "template"]

  connect() {
    this.initializeSortable()
    this.updateIngredientOrder()
  }

  disconnect() {
    if ($(this.listTarget).sortable("instance")) {
      $(this.listTarget).sortable("destroy")
    }
  }

  add(event) {
    event.preventDefault()
    const timestamp = new Date().getTime()
    const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, timestamp)
    this.listTarget.insertAdjacentHTML("beforeend", content)
    this.updateIngredientOrder()

    // Autofocus the new ingredient's first field
    const newIngredient = this.listTarget.lastElementChild
    const autofocusEl = newIngredient?.querySelector(".autofocus-on-new")
    if (autofocusEl) autofocusEl.focus()
  }

  remove(event) {
    event.preventDefault()
    const wrapper = event.currentTarget.closest(".nested-fields")
    if (!wrapper) return

    const destroyField = wrapper.querySelector("input[name*='_destroy']")

    if (destroyField) {
      destroyField.value = "1"
      wrapper.style.display = "none"
    } else {
      wrapper.remove()
    }

    this.updateIngredientOrder()
  }

  updateIngredientOrder() {
    const allIngredients = Array.from(this.listTarget.querySelectorAll(".nested-fields"))
    // Exclude ingredients marked for destruction (hidden)
    const activeIngredients = allIngredients.filter(el => {
      const destroyField = el.querySelector("input[name*='_destroy']")
      return !destroyField || destroyField.value !== "1"
    })

    activeIngredients.forEach((ingredient, index) => {
      const orderField = ingredient.querySelector(".ingredientOrderField")
      if (orderField) orderField.value = index + 1
    })
  }

  initializeSortable() {
    $(this.listTarget).sortable({
      handle: ".slide",
      update: () => this.updateIngredientOrder()
    })
  }
}
