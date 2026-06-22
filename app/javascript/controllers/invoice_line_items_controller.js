import { Controller } from "@hotwired/stimulus"

// Recomputes each line item's amount and the invoice total live as the user
// edits hours/rate or marks a line for removal on the invoice edit page.
export default class extends Controller {
  static targets = ["row", "total"]

  connect() {
    this.recalculate()
  }

  recalculate() {
    let total = 0

    this.rowTargets.forEach(row => {
      const quantity = parseFloat(this.fieldValue(row, "quantity")) || 0
      const rate = parseFloat(this.fieldValue(row, "rate")) || 0
      const destroyed = this.isDestroyed(row)
      const amount = quantity * rate

      const amountCell = row.querySelector('[data-line-item="amount"]')
      if (amountCell) amountCell.textContent = this.formatCurrency(amount)

      row.classList.toggle("line-item--removed", destroyed)
      if (!destroyed) total += amount
    })

    this.totalTarget.textContent = this.formatCurrency(total)
  }

  fieldValue(row, name) {
    const el = row.querySelector(`[data-line-item="${name}"]`)
    return el ? el.value : ""
  }

  isDestroyed(row) {
    const checkbox = row.querySelector('[data-line-item="destroy"]')
    return checkbox ? checkbox.checked : false
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("en-US", {
      style: "currency",
      currency: "USD"
    }).format(value)
  }
}
