import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["addForm"]
  
  showForm() {
    this.addFormTarget.classList.remove("hidden")
  }
  
  hideForm() {
    this.addFormTarget.classList.add("hidden")
  }
}
