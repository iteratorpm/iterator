import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "label"]

  connect() {
    this.handleOutsideClick = this.handleOutsideClick.bind(this)
  }

  toggle() {
    if (this.menuTarget.classList.contains("hidden")) {
      this.show()
    } else {
      this.hide()
    }
  }

  show() {
    this.menuTarget.classList.remove("hidden")
    document.addEventListener("click", this.handleOutsideClick)
  }

  hide() {
    this.menuTarget.classList.add("hidden")
    document.removeEventListener("click", this.handleOutsideClick)
  }

  select(event) {
    const filterValue = event.currentTarget.dataset.filter
    const filterText = event.currentTarget.textContent.trim()
    
    this.labelTarget.textContent = filterText
    this.hide()
  }

  handleOutsideClick(event) {
    if (!this.element.contains(event.target)) {
      this.hide()
    }
  }

  disconnect() {
    document.removeEventListener("click", this.handleOutsideClick)
  }
}
