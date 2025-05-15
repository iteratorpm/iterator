import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "header"]

  toggle() {
    this.formTarget.classList.toggle("hidden")

    this.element.querySelector("[name$='[name]']")?.focus()
  }

  close() {
    this.formTarget.classList.add("hidden")
  }
}
