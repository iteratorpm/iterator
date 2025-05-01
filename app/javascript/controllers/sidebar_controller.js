import { Controller } from "@hotwired/stimulus"
import Cookies from "js-cookie"

export default class extends Controller {
  static targets = ["item", "label", "toggle"]
  static values = {
    collapsed: Boolean,
    projectId: Number
  }

  connect() {
    this.loadState()
    this.applyCollapsedState()
  }

  toggleCollapse() {
    this.collapsedValue = !this.collapsedValue
    this.applyCollapsedState()
    this.saveState()
  }

  togglePanel(event) {
    const panelName = event.currentTarget.dataset.panelName
    const checkbox = document.querySelector(`input[name="toggle-${panelName}"]`)
    
    // Toggle the checkbox which will trigger persist
    checkbox.checked = !checkbox.checked
    checkbox.dispatchEvent(new Event('change'))
    
    // Update active state
    this.updateActiveItems()
  }

  updateActiveItems() {
    this.itemTargets.forEach(item => {
      const panelName = item.dataset.panelName
      const isActive = document.querySelector(`input[name="toggle-${panelName}"]`).checked
      item.classList.toggle('bg-gray-300', isActive)
    })
  }

  applyCollapsedState() {
    if (this.collapsedValue) {
      this.element.classList.add('collapsed')
      this.labelTargets.forEach(label => label.classList.add('hidden'))
    } else {
      this.element.classList.remove('collapsed')
      this.labelTargets.forEach(label => label.classList.remove('hidden'))
    }
  }

  loadState() {
    const state = Cookies.get(`project_${this.projectIdValue}_sidebar`)
    if (state) {
      try {
        const { collapsed } = JSON.parse(state)
        this.collapsedValue = collapsed
        this.applyCollapsedState()
      } catch (e) {
        console.error("Failed to parse sidebar state", e)
      }
    }
  }

  saveState() {
    const state = {
      collapsed: this.collapsedValue
    }
    Cookies.set(`project_${this.projectIdValue}_sidebar`, JSON.stringify(state), { expires: 365 })
  }
}
