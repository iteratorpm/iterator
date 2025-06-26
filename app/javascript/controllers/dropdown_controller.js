import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "button", "menu", "search", "selected", "items", "item"]
  static values = { selected: String }

  connect() {
    this.setupAriaAttributes()
    this.initializeSelectedItem()
    document.addEventListener("click", this.closeOnClickOutside.bind(this))
  }

  disconnect() {
    document.removeEventListener("click", this.closeOnClickOutside.bind(this))
  }

  toggle(e) {
    e.preventDefault()
    this.menuTarget.classList.toggle("hidden")
    const isExpanded = !this.menuTarget.classList.contains("hidden")
    this.buttonTarget.setAttribute("aria-expanded", isExpanded)
    
    if (isExpanded) {
      if (this.hasSearchTarget) {
        this.searchTarget.focus()
      }
      this.highlightSelectedItem()
    }
  }

  select(e) {
    e.preventDefault()
    const item = e.currentTarget.closest("[data-value]")
    if (!item) return

    this.selectedValue = item.dataset.value
    this.updateDisplay(item)
    this.menuTarget.classList.add("hidden")
    this.buttonTarget.setAttribute("aria-expanded", "false")
  }

  filter() {
    const term = this.searchTarget.value.toLowerCase()
    this.itemsTargets.forEach(item => {
      const matches = item.textContent.toLowerCase().includes(term)
      item.classList.toggle("hidden", !matches)
    })
  }

  initializeSelectedItem() {
    const initialValue = this.inputTarget.value
    const initialItem = this.itemTargets.find(item => item.dataset.value === initialValue)
    if (initialItem) {
      this.updateDisplay(initialItem)
    } else if (this.hasSelectedTarget) {
      this.selectedTarget.innerHTML = "<span class='text-gray-400'>Select a user</span>"
    }
  }

  updateDisplay(selectedItem) {
    const displayContent = selectedItem.querySelector(".dropdown_content")?.cloneNode(true)
    if (!displayContent || !this.hasSelectedTarget) return

    this.selectedTarget.innerHTML = ''
    this.selectedTarget.appendChild(displayContent)

    this.inputTarget.value = this.selectedValue = selectedItem.dataset.value

    this.itemTargets.forEach(item => {
      item.classList.toggle("bg-gray-100", item.dataset.value === this.selectedValue)
    })
  }

  highlightSelectedItem() {
    this.itemTargets.forEach(item => {
      if (item.dataset.value === this.selectedValue) {
        item.scrollIntoView({ block: "nearest" })
      }
    })
  }

  closeOnClickOutside(e) {
    if (!this.element.contains(e.target)) {
      this.menuTarget.classList.add("hidden")
      this.buttonTarget.setAttribute("aria-expanded", "false")
    }
  }

  setupAriaAttributes() {
    this.buttonTarget.setAttribute("aria-haspopup", "true")
    this.buttonTarget.setAttribute("aria-expanded", "false")
    this.menuTarget.setAttribute("aria-labelledby", this.buttonTarget.id)
  }
}
