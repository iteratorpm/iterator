import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "input"]

  connect() {
    this.formTarget.addEventListener("dragover", e => {
      e.preventDefault()
      this.formTarget.classList.add("ring-2", "ring-blue-300")
    })

    this.formTarget.addEventListener("dragleave", () => {
      this.formTarget.classList.remove("ring-2", "ring-blue-300")
    })

    this.formTarget.addEventListener("drop", e => {
      e.preventDefault()
      this.formTarget.classList.remove("ring-2", "ring-blue-300")

      const files = Array.from(e.dataTransfer.files)
      if (files.length > 0) {
        this.inputTarget.files = e.dataTransfer.files
        this.formTarget.requestSubmit()
      }
    })
  }
}
