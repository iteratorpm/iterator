import { Controller } from "@hotwired/stimulus"
import { patch } from '@rails/request.js'

export default class extends Controller {
  static targets = ["form", "header"]

  estimate(event) {
    event.preventDefault()
    event.stopPropagation()

    const pointValue = event.currentTarget.dataset.storyPointValue
    const storyId = this.element.dataset.id

    patch(`${location.href}/stories/${storyId}`, {
      headers: {
        "Accept": "text/vnd.turbo-stream.html",
        "Content-Type": "application/json"
      },
      body: JSON.stringify({ story: {estimate: pointValue} })
    })
  }

  updateState(event) {
    event.preventDefault()
    event.stopPropagation()

    const state = event.currentTarget.dataset.storyStateValue
    const storyId = this.element.dataset.id

    if (state === "rejected") {
      // Open the rejection modal via Turbo Frame
      const modalUrl = `${location.href}/stories/${storyId}/rejection`

      // Load rejection form into modal turbo-frame
      Turbo.visit(modalUrl, {
        frame: "modal"
      })

      return
    }

    // Otherwise, continue with normal state update
    patch(`${location.href}/stories/${storyId}`, {
      headers: {
        "Accept": "text/vnd.turbo-stream.html",
        "Content-Type": "application/json"
      },
      body: JSON.stringify({ story: { state: state } })
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
