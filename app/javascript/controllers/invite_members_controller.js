import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["searchInput", "resultsContainer", "resultTemplate", "submitButton", "form"]
  static values = { url: String }

  initialize() {
    this.search = _.debounce(this.search.bind(this), 300)
    this.selectedEmails = new Set()
  }

  connect() {
    this.clone = this.resultTemplateTarget.content
  }

  search(event) {
    const term = this.searchInputTarget.value.trim()
    if (term.length < 2) {
      this.resultsContainerTarget.classList.add('hidden')
      return
    }

    fetch(`${this.urlValue}?term=${encodeURIComponent(term)}`)
      .then(response => response.json())
      .then(users => {
        // Ransack returns the full user objects
        this.displayResults(users)
      })
      .catch(error => console.error('Error:', error))
  }

  displayResults(users) {
    this.resultsContainerTarget.innerHTML = ''

    if (users.length === 0) {
      this.resultsContainerTarget.classList.add('hidden')
      return
    }

    users.forEach(user => {
      const clone = this.clone.cloneNode(true)
      clone.querySelector('[data-invite-members-target="initials"]').textContent = user.initials
      clone.querySelector('[data-invite-members-target="name"]').textContent = user.name
      clone.querySelector('[data-invite-members-target="email"]').textContent = user.email
      clone.querySelector('li').dataset.email = user.email
      this.resultsContainerTarget.appendChild(clone)
    })

    this.resultsContainerTarget.classList.remove('hidden')
  }

  selectUser(event) {
    const email = event.currentTarget.dataset.email
    this.selectedEmails.add(email)
    this.updateSearchInput()
    this.updateSubmitButton()
    this.resultsContainerTarget.classList.add('hidden')
  }

  updateSearchInput() {
    this.searchInputTarget.value = Array.from(this.selectedEmails).join(', ')
  }

  updateSubmitButton() {
    const count = this.selectedEmails.size
    this.submitButtonTarget.textContent = `Invite (${count})`
    this.submitButtonTarget.disabled = count === 0
    this.submitButtonTarget.classList.toggle('opacity-50', count === 0)
    this.submitButtonTarget.classList.toggle('cursor-not-allowed', count === 0)
  }

  handleKeydown(event) {
    if (event.key === 'Escape') {
      this.resultsContainerTarget.classList.add('hidden')
    }
  }
}
