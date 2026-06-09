import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list", "template"]

  connect() {
    this.initializeSortable()
    this.updateStepOrder()
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
    this.updateStepOrder()

    // Autofocus the new step's description field
    const newStep = this.listTarget.lastElementChild
    const autofocusEl = newStep?.querySelector(".autofocus-on-new")
    if (autofocusEl) autofocusEl.focus()
  }

  remove(event) {
    event.preventDefault()
    // Use currentTarget (the button with data-action) not target (possibly a child icon)
    const wrapper = event.currentTarget.closest(".nested-fields")
    if (!wrapper) return

    const destroyField = wrapper.querySelector("input[name*='_destroy']")

    if (destroyField) {
      // Mark for destruction and hide — works for both persisted and new records.
      // Rails will skip records with _destroy=1 and no id (new unsaved), and
      // will delete records with _destroy=1 and a valid id (existing).
      destroyField.value = "1"
      wrapper.style.display = "none"
    } else {
      wrapper.remove()
    }

    this.updateStepOrder()
  }

  updateStepOrder() {
    const allSteps = Array.from(this.listTarget.querySelectorAll(".nested-fields"))
    // Exclude steps marked for destruction (hidden)
    const activeSteps = allSteps.filter(el => {
      const destroyField = el.querySelector("input[name*='_destroy']")
      return !destroyField || destroyField.value !== "1"
    })

    activeSteps.forEach((step, index) => {
      const orderField = step.querySelector(".stepOrderField")
      if (orderField) orderField.value = index + 1
    })
  }

  initializeSortable() {
    $(this.listTarget).sortable({
      handle: ".slide",
      update: () => this.updateStepOrder()
    })
  }
}
