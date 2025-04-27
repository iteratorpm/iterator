import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "element" ]

  connect() {
    this.focusOnFirstElement()
  }

  focusOnFirstElement() {
    this.elementTargets[0].focus()
  }

}
