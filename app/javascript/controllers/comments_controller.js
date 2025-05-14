import { Controller } from "@hotwired/stimulus"
import Cookies from "js-cookie"

export default class extends Controller {
  static targets = ["commentList"]
  static values = { 
    sort: { type: String, default: "Newest to Oldest" } 
  }

  connect() {
    this.sortValue = Cookies.get("comments_sort") || this.sortValue
    this.applySort()
  }

  sort(event) {
    this.sortValue = event.currentTarget.dataset.value
    Cookies.set("comments_sort", this.sortValue, { expires: 365 })
    this.applySort()
    this.closeDropdown()
  }

  applySort() {
    const list = this.commentListTarget
    const items = Array.from(list.querySelectorAll("[data-comment-id]"))
    
    const sorted = items.sort((a, b) => {
      return this.sortValue === "Newest to Oldest" 
        ? b.dataset.timestamp.localeCompare(a.dataset.timestamp)
        : a.dataset.timestamp.localeCompare(b.dataset.timestamp)
    })

    sorted.forEach(el => list.appendChild(el))
  }

  closeDropdown() {
    const dropmenu = this.element.querySelector('[data-dropmenu-target="menu"]')
    if (dropmenu) dropmenu.classList.add('hidden')
  }
}
