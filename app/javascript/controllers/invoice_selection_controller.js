import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["selectAll", "entry", "total"]

  connect() {
    this.updateTotal()
  }

  toggleAll() {
    const checked = this.selectAllTarget.checked
    this.entryTargets.forEach(checkbox => {
      checkbox.checked = checked
    })
    this.updateTotal()
  }

  updateTotal() {
    let total = 0
    this.entryTargets.forEach(checkbox => {
      if (checkbox.checked) {
        const row = checkbox.closest(".entry")
        const hoursEl = row.querySelector("[data-hours]")
        const hours = parseFloat(hoursEl.dataset.hours)
        const rate = parseFloat(hoursEl.dataset.rate)
        total += hours * rate
      }
    })

    this.totalTarget.textContent = new Intl.NumberFormat("en-US", {
      style: "currency",
      currency: "USD"
    }).format(total)

    // Update select all checkbox state
    const allChecked = this.entryTargets.every(c => c.checked)
    const someChecked = this.entryTargets.some(c => c.checked)
    this.selectAllTarget.checked = allChecked
    this.selectAllTarget.indeterminate = someChecked && !allChecked
  }
}
