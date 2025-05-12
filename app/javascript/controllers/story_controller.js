import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "header"]

  estimate(event) {
    event.preventDefault()
    event.stopPropagation()

    const pointValue = event.currentTarget.dataset.storyPointValue
    const storyId = this.element.id.replace("story_", "") // Adjust if `dom_id` format differs

    fetch(`${location.href}/stories/${storyId}`, {
      method: "PATCH",
      headers: {
        "Accept": "text/vnd.turbo-stream.html",
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content
      },
      body: JSON.stringify({ story: {estimate: pointValue} })
    })
  }

  open() {
    this.headerTarget.classList.add("hidden")
    this.formTarget.classList.remove("hidden")

    this.element.querySelector("[name$='[name]']")?.focus()
  }

  close() {
    this.formTarget.classList.add("hidden")
    this.headerTarget.classList.remove("hidden")
  }
}
