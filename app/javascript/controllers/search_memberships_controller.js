import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "clear", "item"]

  connect() {
    this.toggleClearButton()
  }

  filter() {
    const searchTerm = this.inputTarget.value.toLowerCase()
    this.toggleClearButton()

    this.itemTargets.forEach(item => {
      const name = item.dataset.memberName.toLowerCase()
      const email = item.dataset.memberEmail.toLowerCase()

      // Create a fuzzy regex pattern from the search term, like: "e" => /e/, "bn" => /b.*n/
      const fuzzyPattern = new RegExp(searchTerm.split('').join('.*'), 'i')

      const matches = fuzzyPattern.test(name) || fuzzyPattern.test(email)
      item.classList.toggle('hidden', !matches)
    })
  }

  clear() {
    this.inputTarget.value = ""
    this.inputTarget.focus()
    this.toggleClearButton()
    this.filter() // This will show all items again
  }

  toggleClearButton() {
    this.clearTarget.classList.toggle("hidden", !this.inputTarget.value)
  }

  handleKeydown(event) {
    if (event.key === "Escape") {
      this.clear()
      event.preventDefault()
    }
  }
}
