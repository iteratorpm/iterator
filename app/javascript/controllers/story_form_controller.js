import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["titleInput"]

  connect() {
    this.resizeTextarea()
  }

  resizeTextarea() {
    const textarea = this.titleInputTarget
    const shadow = textarea.nextElementSibling
    shadow.innerHTML = textarea.value.replace(/\n/g, '<br>') + '<span>w</span>'
    textarea.style.height = shadow.offsetHeight + 'px'
  }

  collapse() {
    // Handle collapse logic
    this.element.classList.add('hidden')
  }

  cancel() {
    // Handle cancel logic
    this.element.remove()
  }
}
