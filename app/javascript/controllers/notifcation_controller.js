import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["bell", "counter"]
  static values = { url: String, unreadCount: Number }

  connect() {
    if (this.hasUnreadCountValue && this.unreadCountValue > 0) {
      this.updateDocumentTitle()
    }
    
    this.pollingInterval = setInterval(() => this.checkNewNotifications(), 60000)
  }

  disconnect() {
    clearInterval(this.pollingInterval)
  }

  markAsRead(event) {
    event.preventDefault()
    const url = event.currentTarget.dataset.url || this.data.get("url")
    
    fetch(url, {
      method: 'POST',
      headers: {
        'X-CSRF-Token': document.querySelector("[name='csrf-token']").content,
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      }
    }).then(response => {
      if (response.ok) {
        this.element.classList.remove("bg-blue-50")
        this.updateUnreadCount(-1)
      }
    })
  }

  checkNewNotifications() {
    fetch(this.urlValue, {
      headers: {
        'Accept': 'application/json'
      }
    })
    .then(response => response.json())
    .then(data => {
      if (data.unread_count > this.unreadCountValue) {
        this.updateUnreadCount(data.unread_count - this.unreadCountValue)
        this.showNewNotificationBadge()
      }
    })
  }

  updateUnreadCount(change) {
    const newCount = this.unreadCountValue + change
    this.unreadCountValue = newCount > 0 ? newCount : 0
    
    if (this.hasCounterTarget) {
      this.counterTarget.style.display = this.unreadCountValue > 0 ? 'block' : 'none'
    }
    
    this.updateDocumentTitle()
  }

  showNewNotificationBadge() {
    if (this.hasBellTarget) {
      this.bellTarget.classList.add('animate-pulse', 'text-yellow-500')
      setTimeout(() => {
        this.bellTarget.classList.remove('animate-pulse', 'text-yellow-500')
      }, 3000)
    }
  }

  updateDocumentTitle() {
    const baseTitle = document.title.replace(/^\(\d+\) /, '')
    document.title = this.unreadCountValue > 0 
      ? `(${this.unreadCountValue}) ${baseTitle}`
      : baseTitle
  }
}
