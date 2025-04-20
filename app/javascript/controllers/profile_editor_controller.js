import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "editorTab", 
    "previewTab",
    "editorSection",
    "previewSection",
    "previewContent",
    "form",
    "editor",
    "submitButton"
  ]

  connect() {
    this.activeTabClass = "border-blue-500 text-blue-600"
    this.inactiveTabClass = "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300"
    this.activateEditorTab()
  }

  showEditor() {
    this.activateEditorTab()
    this.editorSectionTarget.classList.remove('hidden')
    this.previewSectionTarget.classList.add('hidden')
  }

  showPreview() {
    this.activatePreviewTab()
    this.editorSectionTarget.classList.add('hidden')
    this.previewSectionTarget.classList.remove('hidden')
    
    // Fetch the rendered preview from the server
    this.fetchPreview()
  }

  fetchPreview() {
    this.previewContentTarget.innerHTML = '<div class="text-gray-500">Loading preview...</div>'

    const formData = new FormData(this.formTarget)
    const content = this.editorTarget.value
    
    fetch(this.formTarget.action + '/preview', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector("[name='csrf-token']").content,
        'Accept': 'application/json'
      },
      body: JSON.stringify({ content: content })
    })
    .then(response => response.json())
    .then(data => {
      this.previewContentTarget.innerHTML = data.html || "Preview not available"
    })
    .catch(error => {
      console.error('Error fetching preview:', error)
      this.previewContentTarget.innerHTML = "Error loading preview"
    })
  }

  activateEditorTab() {
    this.editorTabTarget.classList.remove(...this.inactiveTabClass.split(' '))
    this.editorTabTarget.classList.add(...this.activeTabClass.split(' '))
    this.previewTabTarget.classList.remove(...this.activeTabClass.split(' '))
    this.previewTabTarget.classList.add(...this.inactiveTabClass.split(' '))
  }

  activatePreviewTab() {
    this.previewTabTarget.classList.remove(...this.inactiveTabClass.split(' '))
    this.previewTabTarget.classList.add(...this.activeTabClass.split(' '))
    this.editorTabTarget.classList.remove(...this.activeTabClass.split(' '))
    this.editorTabTarget.classList.add(...this.inactiveTabClass.split(' '))
  }
}
