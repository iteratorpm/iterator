import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form"]

  connect() {}

  close() {
    this.element.classList.add("hidden")
  }

  resetAndClose(event) {
    event.preventDefault()

    if (event.detail.success) {
      const form = this.formTarget
      form.reset()

      this.close()
    }
  }
}
