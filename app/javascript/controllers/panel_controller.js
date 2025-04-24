import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["addStoryCard"]
  
  addStory() {
    this.addStoryCardTarget.classList.remove("hidden")
  }
  
  cancelAddStory() {
    this.addStoryCardTarget.classList.add("hidden")
  }
}
