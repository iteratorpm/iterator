import { Controller } from "@hotwired/stimulus"
import debounce from "lodash.debounce"

export default class extends Controller {
  static targets = [
    "searchInput",
    "resultsContainer",
    "resultTemplate",
    "submitButton",
    "hiddenEmailsInput", // The hidden field for submission
    "pillsContainer",    // The container for the email pills
    "pillTemplate"       // The template for a single pill
  ]
  static values = { url: String }

  initialize() {
    // Debounce the search function to avoid excessive requests
    this.search = debounce(this.search, 300)
    this.selectedEmails = new Set()
  }

  connect() {
    this.resultClone = this.resultTemplateTarget.content
    this.pillClone = this.pillTemplateTarget.content
  }

  // Focus the text input when clicking anywhere in the container
  focusInput() {
    this.searchInputTarget.focus()
  }

  // --- Search and Selection ---

  search() {
    const term = this.searchInputTarget.value.trim()
    if (term.length < 2) {
      this.resultsContainerTarget.classList.add('hidden')
      return
    }

    // Don't show search results if the input value is already a selected email
    if (this.selectedEmails.has(term.toLowerCase())) {
        return;
    }

    fetch(`${this.urlValue}?term=${encodeURIComponent(term)}`)
      .then(response => response.json())
      .then(users => this.displayResults(users))
      .catch(error => console.error('Error:', error))
  }

  displayResults(users) {
    this.resultsContainerTarget.innerHTML = ''

    const unselectedUsers = users.filter(user => !this.selectedEmails.has(user.email))

    if (unselectedUsers.length === 0) {
      this.resultsContainerTarget.classList.add('hidden')
      return
    }

    unselectedUsers.forEach(user => {
      const clone = this.resultClone.cloneNode(true)
      clone.querySelector('[data-invite-members-target="initials"]').textContent = user.initials
      clone.querySelector('[data-invite-members-target="name"]').textContent = user.name
      clone.querySelector('[data-invite-members-target="email"]').textContent = user.email
      clone.querySelector('li').dataset.email = user.email
      this.resultsContainerTarget.appendChild(clone)
    })

    this.resultsContainerTarget.classList.remove('hidden')
  }

  // Called when a user is clicked from the search results
  selectUser(event) {
    const email = event.currentTarget.dataset.email
    this.addEmail(email)
    this.searchInputTarget.value = ''
    this.resultsContainerTarget.classList.add('hidden')
  }

  // --- Email Pill Management ---

  handleKeydown(event) {
    if (event.key === 'Escape') {
      this.resultsContainerTarget.classList.add('hidden')
    }

    if (event.key === 'Enter') {
      event.preventDefault() // Prevent form submission
      const emails = this.searchInputTarget.value.trim().split(/[\s,]+/).filter(e => e)
      emails.forEach(email => this.addEmail(email))
      this.searchInputTarget.value = ''
      this.resultsContainerTarget.classList.add('hidden')
    }
    
    // Allow removing the last pill with backspace if the input is empty
    if (event.key === 'Backspace' && this.searchInputTarget.value === '') {
        const lastPill = this.pillsContainerTarget.lastElementChild;
        if (lastPill) {
            this.removePill({ currentTarget: lastPill.querySelector('button') });
        }
    }
  }

  addEmail(email) {
    const cleanEmail = email.toLowerCase().trim()
    
    // Simple regex for email validation
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    if (!emailRegex.test(cleanEmail) || this.selectedEmails.has(cleanEmail)) {
      return
    }

    this.selectedEmails.add(cleanEmail)
    this.renderPill(cleanEmail)
    this.updateFormState()
  }

  renderPill(email) {
    const clone = this.pillClone.cloneNode(true)
    const pillElement = clone.querySelector('span')
    pillElement.dataset.email = email
    pillElement.querySelector('[data-invite-members-target="pillEmail"]').textContent = email
    this.pillsContainerTarget.appendChild(clone)
  }

  removePill(event) {
    const pill = event.currentTarget.closest('span')
    const email = pill.dataset.email
    
    this.selectedEmails.delete(email)
    pill.remove()
    this.updateFormState()
  }
  
  // --- Form State ---

  updateFormState() {
    this.updateHiddenInput()
    this.updateSubmitButton()
  }

  updateHiddenInput() {
    this.hiddenEmailsInputTarget.value = Array.from(this.selectedEmails).join(', ')
  }

  updateSubmitButton() {
    const count = this.selectedEmails.size
    this.submitButtonTarget.textContent = `Invite (${count})`
    this.submitButtonTarget.disabled = count === 0
    this.submitButtonTarget.classList.toggle('opacity-50', count === 0)
    this.submitButtonTarget.classList.toggle('cursor-not-allowed', count === 0)
  }
}
