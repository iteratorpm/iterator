import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "header"]

  open() {
    this.headerTarget.classList.add("hidden")
    this.formTarget.classList.remove("hidden")

    this.element.querySelector("[name$='[name]']")?.focus()
  }

  close() {
    this.formTarget.classList.add("hidden")
    this.headerTarget.classList.remove("hidden")
  }
}
