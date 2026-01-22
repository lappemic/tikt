import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["subproject"]

  reset(event) {
    if (event.detail.success) {
      this.element.reset()
      // Focus the first input
      const firstInput = this.element.querySelector("select, input:not([type='hidden'])")
      if (firstInput) firstInput.focus()
      // Clear subproject dropdown
      if (this.hasSubprojectTarget) {
        this.subprojectTarget.innerHTML = '<option value="">No Subproject</option>'
      }
    }
  }

  async projectChanged(event) {
    const projectId = event.target.value
    const select = this.subprojectTarget

    if (!projectId) {
      select.innerHTML = '<option value="">No Subproject</option>'
      return
    }

    try {
      const response = await fetch(`/projects/${projectId}/subprojects`)
      const subprojects = await response.json()

      let options = '<option value="">No Subproject</option>'
      subprojects.forEach(sp => {
        options += `<option value="${sp.id}">${sp.name}</option>`
      })
      select.innerHTML = options
    } catch (error) {
      console.error("Failed to load subprojects:", error)
    }
  }
}
