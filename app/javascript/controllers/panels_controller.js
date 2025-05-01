import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel"]

  toggleVisibility(event) {
    const { panel, visible } = event.detail
    const panelElement = this.panelTargets.find(el => el.dataset.panel === panel)
    
    if (panelElement) {
      panelElement.classList.toggle('hidden', !visible)
      
      // Load content if becoming visible and not already loaded
      if (visible && !panelElement.hasAttribute('loaded')) {
        panelElement.src = panelElement.dataset.src
        panelElement.setAttribute('loaded', 'true')
      }
    }
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
