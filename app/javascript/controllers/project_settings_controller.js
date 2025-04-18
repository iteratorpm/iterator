import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "accountSelect", "bugsWarning", "bugsCheckbox"
  ]

  toggleAccountSelect(event) {
    event.preventDefault()
    this.accountSelectTarget.classList.toggle("hidden")
  }

  toggleBugsWarning() {
    if (this.bugsCheckboxTarget.checked) {
      this.bugsWarningTarget.classList.remove("hidden")
    } else {
      this.bugsWarningTarget.classList.add("hidden")
    }
  }
}
