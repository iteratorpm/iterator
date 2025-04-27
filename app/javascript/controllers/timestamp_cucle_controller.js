import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["timestamp", "message"]
  
  connect() {
    this.index = 0
    this.timestamps = this.timestampTargets
    this.showCurrentTimestamp()
  }
  
  cycle(event) {
    event.preventDefault()
    this.index = (this.index + 1) % (this.timestamps.length + 1)
    this.showCurrentTimestamp()
  }
  
  showCurrentTimestamp() {
    // Hide all timestamps
    this.timestampTargets.forEach(el => el.classList.add('hidden'))
    this.messageTarget.classList.add('hidden')
    
    if (this.index === 0) {
      // Show the first timestamp
      this.timestamps[0].classList.remove('hidden')
    } else if (this.index === 1 && this.timestamps[1]) {
      // Show the second timestamp if it exists
      this.timestamps[1].classList.remove('hidden')
    } else {
      // Show saving message
      this.messageTarget.classList.remove('hidden')
      // Reset index after showing message
      setTimeout(() => {
        this.index = 0
        this.showCurrentTimestamp()
      }, 1000)
    }
  }
}
