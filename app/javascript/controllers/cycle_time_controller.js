import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["displaySelect", "iterationSelect"]
  
  connect() {
    this.displaySelectTarget.addEventListener('change', this.updateDisplay.bind(this))
    this.iterationSelectTarget.addEventListener('change', this.updateIteration.bind(this))
  }
  
  updateDisplay(event) {
    // Handle display type change
    const displayType = event.target.value
    // Implement logic to update the chart based on display type
  }
  
  updateIteration(event) {
    // Handle iteration selection change
    const iterationId = event.target.value
    // Implement logic to load stories for selected iteration
  }
}
