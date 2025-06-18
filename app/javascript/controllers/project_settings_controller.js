import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "organizationDisplay", 
    "organizationSelect", 
    "bugsWarning", 
    "bugsCheckbox",
    "priorityCheckbox",
    "priorityOptions",
    "deleteForm",
    "archiveForm",
    "pointScaleSelect",
    "customPointScaleField"
  ]

  // Organization selection methods
  toggleOrganizationSelect(event) {
    event.preventDefault()
    this.organizationDisplayTarget.classList.add("hidden")
    this.organizationSelectTarget.classList.remove("hidden")
  }

  saveOrganization(event) {
    event.preventDefault()
    // Here you could add logic to save via AJAX if needed
    // For now, we'll just hide the select and show the display
    this.cancelOrganizationSelect(event)
  }

  cancelOrganizationSelect(event) {
    event.preventDefault()
    this.organizationDisplayTarget.classList.remove("hidden")
    this.organizationSelectTarget.classList.add("hidden")
  }

  // Priority field methods
  togglePriorityOptions() {
    if (this.priorityCheckboxTarget.checked) {
      this.priorityOptionsTarget.classList.remove("hidden")
    } else {
      this.priorityOptionsTarget.classList.add("hidden")
    }
  }

  // Point scale methods
  toggleCustomPointScale(event) {
    const selectedValue = event.target.value
    
    if (selectedValue === 'custom') {
      this.customPointScaleFieldTarget.classList.remove("hidden")
    } else {
      this.customPointScaleFieldTarget.classList.add("hidden")
    }
  }

  // Bugs and chores warning
  toggleBugsWarning() {
    if (this.bugsCheckboxTarget.checked) {
      this.bugsWarningTarget.classList.remove("hidden")
    } else {
      this.bugsWarningTarget.classList.add("hidden")
    }
  }

  // Delete project methods
  showDeleteForm(event) {
    event.preventDefault()
    this.deleteFormTarget.classList.remove("hidden")
  }

  hideDeleteForm(event) {
    event.preventDefault()
    this.deleteFormTarget.classList.add("hidden")
  }

  // Archive project methods  
  showArchiveForm(event) {
    event.preventDefault()
    this.archiveFormTarget.classList.remove("hidden")
  }

  hideArchiveForm(event) {
    event.preventDefault()
    this.archiveFormTarget.classList.add("hidden")
  }
}
