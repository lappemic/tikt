import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["hours", "amount"]
  static values = { rate: Number }

  reset(event) {
    if (event.detail.success) {
      this.element.querySelector("form")?.reset()
      const firstInput = this.element.querySelector("input:not([type='hidden'])")
      if (firstInput) firstInput.focus()
    }
  }

  calculateAmount() {
    const hours = parseFloat(this.hoursTarget.value)
    if (!isNaN(hours) && hours > 0 && this.rateValue > 0) {
      this.amountTarget.value = (hours * this.rateValue).toFixed(2)
    }
  }
}
