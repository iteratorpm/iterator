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
    const content = formData.get(this.inputName)

    fetch(this.previewUrl, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
      },
      body: JSON.stringify({ markdown: { content } })
    })
      .then(res => res.json())
      .then(data => {
        this.previewContentTarget.innerHTML = data.html
        this.previewContentTarget.classList.remove("hidden")
        this.previewLoadingTarget.classList.add("hidden")
      })
      .catch(() => {
        this.previewContentTarget.innerHTML = '<p class="text-red-500">Preview failed to load.</p>'
        this.previewContentTarget.classList.remove("hidden")
        this.previewLoadingTarget.classList.add("hidden")
      })
  }

  setActiveTab(active, inactive) {
    active.dataset.active = "true"
    inactive.dataset.active = "false"
  }

  get inputName() {
    return this.editorTarget.getAttribute("name")
  }

  get previewUrl() {
    return this.element.dataset.previewUrl
  }
}
