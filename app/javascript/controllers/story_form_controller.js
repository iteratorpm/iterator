import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = []

  connect() {
  }

  collapse() {
    this.element.classList.add('hidden')
  }
}
