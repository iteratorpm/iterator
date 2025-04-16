import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "editButton", "cancelButton", "saveButton", 
    "readMode", "editMode"
  ]

  toggleEdit(event) {
    event.preventDefault()
    const section = event.params.section
    
    this[`${section}EditButtonTarget`].classList.toggle("hidden")
    this[`${section}CancelButtonTarget`].classList.toggle("hidden")
    this[`${section}SaveButtonTarget`].classList.toggle("hidden")
    this[`${section}ReadModeTarget`].classList.toggle("hidden")
    this[`${section}EditModeTarget`].classList.toggle("hidden")
  }

  saveForm(event) {
    event.preventDefault()
    const form = event.target.closest("form")
    const formData = new FormData(form)

    fetch(form.action, {
      method: "PUT",
      body: formData,
      headers: {
        "Accept": "text/vnd.turbo-stream.html",
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
      }
    })
    .then(response => response.text())
    .then(html => {
      Turbo.renderStreamMessage(html)
      this.toggleEdit(event) // Exit edit mode after save
    })
    .catch(error => console.error("Error:", error))
  }
}
