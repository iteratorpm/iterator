import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  submit(event) {
    this.element.requestSubmit()
  }

  submitOnEnter(event) {
    // Only submit if the Enter key is pressed (keyCode 13)
    if (event.keyCode === 13) {
      event.preventDefault()
      this.element.requestSubmit()
    }
  }
}
