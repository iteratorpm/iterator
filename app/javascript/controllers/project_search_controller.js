import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "item", "container"]

  filter() {
    const query = this.inputTarget.value.toLowerCase().trim()
    
    if (query === '') {
      this.showAllItems()
      return
    }

    this.itemTargets.forEach(item => {
      const projectName = item.dataset.projectName
      if (this.fuzzyMatch(projectName, query)) {
        item.style.display = 'block'
      } else {
        item.style.display = 'none'
      }
    })

    this.updateEmptyState()
  }

  fuzzyMatch(text, query) {
    // Simple fuzzy matching algorithm
    let textIndex = 0
    let queryIndex = 0
    
    while (textIndex < text.length && queryIndex < query.length) {
      if (text[textIndex].toLowerCase() === query[queryIndex].toLowerCase()) {
        queryIndex++
      }
      textIndex++
    }
    
    return queryIndex === query.length
  }

  showAllItems() {
    this.itemTargets.forEach(item => {
      item.style.display = 'block'
    })
    this.removeEmptyState()
  }

  updateEmptyState() {
    const visibleItems = this.itemTargets.filter(item => item.style.display !== 'none')
    
    if (visibleItems.length === 0) {
      this.showEmptyState()
    } else {
      this.removeEmptyState()
    }
  }

  showEmptyState() {
    this.removeEmptyState() // Remove existing empty state first
    
    const emptyState = document.createElement('div')
    emptyState.className = 'empty-state text-center py-12 col-span-full'
    emptyState.innerHTML = `
      <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
      </svg>
      <h3 class="mt-2 text-sm font-medium text-gray-900">No projects found</h3>
      <p class="mt-1 text-sm text-gray-500">No projects match your search criteria.</p>
    `
    
    this.containerTarget.appendChild(emptyState)
  }

  removeEmptyState() {
    const emptyState = this.containerTarget.querySelector('.empty-state')
    if (emptyState) {
      emptyState.remove()
    }
  }
}
