import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.resize() // Initial resize
    this.setupObserver()
  }

  disconnect() {
    this.observer?.disconnect()
  }

  setupObserver() {
    this.observer = new IntersectionObserver(
      (entries) => {
        entries.forEach(entry => {
          if (entry.isIntersecting) {
            this.resize()
          }
        })
      },
      { threshold: 0.1 }
    )
    this.observer.observe(this.element)
  }

  resize() {
    // Reset height to get correct scrollHeight
    this.element.style.height = 'auto'
    // Set new height including any border/padding
    this.element.style.height = `${this.element.scrollHeight}px`
  }
}
