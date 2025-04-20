import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["editor", "preview", "previewContent", "previewLoading", "editTab", "previewTab"]

  showEditor() {
    this.editorTarget.classList.remove('hidden')
    this.previewTarget.classList.add('hidden')
    this.setActiveTab(this.editTabTarget, this.previewTabTarget)
  }

  showPreview() {
    this.editorTarget.classList.add('hidden')
    this.previewTarget.classList.remove('hidden')
    this.previewContentTarget.classList.add('hidden')
    this.previewLoadingTarget.classList.remove('hidden')
    this.setActiveTab(this.previewTabTarget, this.editTabTarget)

    this.fetchPreview()
  }

  fetchPreview() {
    const formData = new FormData(this.element)
    const content = formData.get('description_template[description]')

    fetch(this.previewUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector("[name='csrf-token']").content,
        'Accept': 'application/json'
      },
      body: JSON.stringify({ template: { description: content } })
    })
    .then(response => response.json())
    .then(data => {
      this.previewContentTarget.innerHTML = data.html
      this.previewContentTarget.classList.remove('hidden')
      this.previewLoadingTarget.classList.add('hidden')
    })
    .catch(error => {
      this.previewContentTarget.innerHTML = '<p class="text-red-500">Error loading preview</p>'
      this.previewContentTarget.classList.remove('hidden')
      this.previewLoadingTarget.classList.add('hidden')
    })
  }

  setActiveTab(activeTab, inactiveTab) {
    activeTab.dataset.active = "true"
    inactiveTab.dataset.active = "false"
  }

  get previewUrl() {
    return `${this.element.action}/preview`
  }
}
