import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "submit"]
  
  connect() {
    // Initial validation
    this.validate()
  }

  disconnect() {
  }

  validate() {
    if (!this.hasSubmitTarget) return
    
    // Check if any input has content
    const hasContent = this.inputTargets.some(
      input => input.value.trim().length > 0
    )
    
    this.submitTarget.disabled = !hasContent
  }
}
