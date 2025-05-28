import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["editButton", "cancelButton", "saveButton", "readMode", "editMode"]
  static values = { section: String }

  connect() {
    console.log("NotificationSettings controller connected")
  }

  toggleEdit(event) {
    event.preventDefault()
    
    const section = event.params.section
    const editButton = this.getTargetBySection(section, "editButton")
    const cancelButton = this.getTargetBySection(section, "cancelButton")
    const saveButton = this.getTargetBySection(section, "saveButton")
    const readMode = this.getTargetBySection(section, "readMode")
    const editMode = this.getTargetBySection(section, "editMode")

    // Toggle visibility
    editButton.classList.toggle("hidden")
    cancelButton.classList.toggle("hidden")
    saveButton.classList.toggle("hidden")
    readMode.classList.toggle("hidden")
    editMode.classList.toggle("hidden")
  }

  cancelEdit(event) {
    event.preventDefault()
    
    const section = event.params.section
    const editButton = this.getTargetBySection(section, "editButton")
    const cancelButton = this.getTargetBySection(section, "cancelButton")
    const saveButton = this.getTargetBySection(section, "saveButton")
    const readMode = this.getTargetBySection(section, "readMode")
    const editMode = this.getTargetBySection(section, "editMode")

    // Return to read mode
    editButton.classList.remove("hidden")
    cancelButton.classList.add("hidden")
    saveButton.classList.add("hidden")
    readMode.classList.remove("hidden")
    editMode.classList.add("hidden")
  }

  async saveForm(event) {
    event.preventDefault()
    
    const section = event.params.section
    const form = this.getFormBySection(section)
    
    if (!form) {
      console.error("Form not found for section:", section)
      return
    }

    const formData = new FormData(form)
    formData.append("section", section)

    try {
      const response = await fetch(form.action, {
        method: "PATCH",
        body: formData,
        headers: {
          "Accept": "text/vnd.turbo-stream.html",
          "X-CSRF-Token": this.getCSRFToken()
        }
      })

      if (response.ok) {
        const html = await response.text()
        Turbo.renderStreamMessage(html)
        
        // Exit edit mode after successful save
        this.exitEditMode(section)
      } else {
        console.error("Failed to save:", response.statusText)
      }
    } catch (error) {
      console.error("Error saving form:", error)
    }
  }

  // Helper methods
  getTargetBySection(section, targetType) {
    const targetName = `${section}_${targetType}`
    const target = this.targets.find(targetName)
    
    if (!target) {
      // Fallback: try to find by data attribute
      return this.element.querySelector(`[data-notification-settings-target="${targetName}"]`)
    }
    
    return target
  }

  getFormBySection(section) {
    return this.element.querySelector(`form[data-section="${section}"]`) ||
           this.element.querySelector(`form:has([name="section"][value="${section}"])`)
  }

  exitEditMode(section) {
    const editButton = this.getTargetBySection(section, "editButton")
    const cancelButton = this.getTargetBySection(section, "cancelButton")
    const saveButton = this.getTargetBySection(section, "saveButton")
    const readMode = this.getTargetBySection(section, "readMode")
    const editMode = this.getTargetBySection(section, "editMode")

    if (editButton) editButton.classList.remove("hidden")
    if (cancelButton) cancelButton.classList.add("hidden")
    if (saveButton) saveButton.classList.add("hidden")
    if (readMode) readMode.classList.remove("hidden")
    if (editMode) editMode.classList.add("hidden")
  }

  getCSRFToken() {
    const token = document.querySelector("[name='csrf-token']")?.content
    if (!token) {
      console.warn("CSRF token not found")
    }
    return token
  }
}
