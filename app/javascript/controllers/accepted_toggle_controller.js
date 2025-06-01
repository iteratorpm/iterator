import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "label"]

  toggle() {
    this.contentTarget.classList.toggle('hidden')
    this.updateLabel()
  }

  updateLabel() {
    const isHidden = this.contentTarget.classList.contains('hidden')
    const count = this.contentTarget.dataset.count
    this.labelTarget.textContent = isHidden 
      ? `Show ${count} accepted ${count === '1' ? 'story' : 'stories'}` 
      : `Hide ${count} accepted ${count === '1' ? 'story' : 'stories'}`
  }
}
