import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    if (this.timeoutValue) {
      setTimeout(() => {
        this.dismiss()
      }, this.timeoutValue)
    }
  }

  dismiss() {
    this.element.remove()
  }

  get timeoutValue() {
    return this.data.get("timeout") || 5000
  }
}
