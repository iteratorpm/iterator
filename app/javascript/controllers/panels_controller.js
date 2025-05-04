import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel"]

  toggleVisibility(event) {
    const { panel, visible } = event.detail
    const panelElement = this.panelTargets.find(el => el.dataset.panel === panel)

    if (panelElement) {
      panelElement.classList.toggle('hidden', !visible)

      // Load content if becoming visible
      if (visible) {
        // Turbo frames need special handling to trigger loading
        if (!panelElement.hasAttribute('complete')) {
          // Method 1: Reload the frame (most reliable)
          panelElement.innerHTML = '' // Clear existing content
          panelElement.reload()

          // OR Method 2: Trigger loading by setting src
          // const src = panelElement.getAttribute('src') || panelElement.dataset.src
          // panelElement.setAttribute('src', src)

          // Mark as loaded
          panelElement.setAttribute('loaded', 'true')
        }
      }
    }

    this.resizePanels()
  }

  resizePanels() {
    // Calculate and adjust panel sizes as needed
    const visiblePanels = this.panelTargets.filter(p => !p.classList.contains('hidden'))
    const containerWidth = this.element.clientWidth

    if (visiblePanels.length > 0) {
      const panelWidth = Math.max(300, containerWidth / visiblePanels.length)
      visiblePanels.forEach(panel => {
        panel.style.width = `${panelWidth}px`
      })
    }
  }
}
