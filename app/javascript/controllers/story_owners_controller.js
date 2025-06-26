import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { storyId: Number }

  addOwner(e) {
    const userId = e.currentTarget.dataset.value
    const storyId = this.storyIdValue;

    fetch(`${location.href}/stories/${storyId}/add_owner`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ user_id: userId })
    })
  }

  removeOwner(event) {
    const userId = event.target.dataset.userId
    if (!userId) return

    fetch(`${location.href}/stories/${this.storyIdValue}/remove_owner`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ user_id: userId })
    })
  }

  toggleOwnerPopup(e) {
    const userId = e.currentTarget.dataset.userId || e.currentTarget.getAttribute("data-user-id")
    const popup = this.element.querySelector(`.story-owner-dropdown[data-owner-id="${userId}"]`)

    if (popup) {
      popup.classList.toggle("hidden")
    }

    this.element.querySelectorAll(".story-owner-dropdown").forEach((el) => {
      if (el !== popup) el.classList.add("hidden")
    })
  }

  connect() {
    document.addEventListener("click", this.handleOutsideClick)
  }

  disconnect() {
    document.removeEventListener("click", this.handleOutsideClick)
  }

  handleOutsideClick = (e) => {
    if (!this.element.contains(e.target)) {
      this.element.querySelectorAll(".story-owner-dropdown").forEach(popup => popup.classList.add("hidden"))
    }
  }
}
