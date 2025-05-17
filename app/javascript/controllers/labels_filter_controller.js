import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["search", "label"]

  filter() {
    const searchTerm = this.searchTarget.value.toLowerCase()
    
    this.labelTargets.forEach(label => {
      const labelName = label.dataset.labelName
      const matchesSearch = labelName.includes(searchTerm)
      
      label.classList.toggle("hidden", !matchesSearch)
    })
  }
}
