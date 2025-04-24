import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["addStoryForm"]
  
  addStory() {
    this.addStoryFormTarget.classList.remove("hidden")
  }
  
  cancelAddStory() {
    this.addStoryFormTarget.classList.add("hidden")
  }
}
