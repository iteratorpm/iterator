import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "menu", "notificationDot", "loading", "content", "notificationsList", 
    "emptyState", "filterContainer", "filterButton", "filterText", "filterMenu",
    "markAllButton", "loadMoreContainer", "loadMoreButton"
  ]

  connect() {
    this.currentFilter = 'all'
    this.currentPage = 1
    this.isOpen = false
    this.notifications = []
    this.unreadCount = 0
    
    // Load initial unread count
    this.loadUnreadCount()
  }

  async loadUnreadCount() {
    try {
      const response = await fetch('/notifications/unread_count.json')
      const data = await response.json()
      this.unreadCount = data.count
      this.updateNotificationDot()
    } catch (error) {
      console.error('Failed to load unread count:', error)
    }
  }

  updateNotificationDot() {
    if (this.unreadCount > 0) {
      this.notificationDotTarget.classList.remove('hidden')
    } else {
      this.notificationDotTarget.classList.add('hidden')
    }
  }

  async toggle(event) {
    event.stopPropagation()
    
    if (this.isOpen) {
      this.hide()
    } else {
      await this.show()
    }
  }

  async show() {
    this.isOpen = true
    this.menuTarget.classList.remove('hidden')
    this.loadingTarget.classList.remove('hidden')
    this.contentTarget.classList.add('hidden')
    
    // Load notifications when opened
    await this.loadNotifications()
  }

  hide(event) {
    if (event && this.element.contains(event.target)) {
      return
    }
    
    this.isOpen = false
    this.menuTarget.classList.add('hidden')
    this.filterMenuTarget.classList.add('hidden')
  }

  async loadNotifications(page = 1) {
    try {
      const params = new URLSearchParams({
        filter: this.currentFilter,
        page: page,
        format: 'json'
      })
      
      const response = await fetch(`/notifications.json?${params}`)
      const data = await response.json()
      
      if (page === 1) {
        this.notifications = data.notifications
        this.renderNotifications()
      } else {
        this.notifications = [...this.notifications, ...data.notifications]
        this.appendNotifications(data.notifications)
      }
      
      this.updateLoadMoreButton(data.has_more, data.next_page)
      this.showContent()
      
    } catch (error) {
      console.error('Failed to load notifications:', error)
      this.showError()
    }
  }

  showContent() {
    this.loadingTarget.classList.add('hidden')
    this.contentTarget.classList.remove('hidden')
    
    if (this.notifications.length === 0) {
      this.emptyStateTarget.classList.remove('hidden')
      this.notificationsListTarget.classList.add('hidden')
    } else {
      this.emptyStateTarget.classList.add('hidden')
      this.notificationsListTarget.classList.remove('hidden')
    }
  }

  renderNotifications() {
    this.notificationsListTarget.innerHTML = ''
    this.notifications.forEach(notification => {
      this.appendNotification(notification)
    })
  }

  appendNotifications(notifications) {
    notifications.forEach(notification => {
      this.appendNotification(notification)
    })
  }

  appendNotification(notification) {
    const notificationElement = this.createNotificationElement(notification)
    this.notificationsListTarget.appendChild(notificationElement)
  }

  createNotificationElement(notification) {
    const div = document.createElement('div')
    const isUnread = !notification.read_at
    const bgClass = isUnread ? 'bg-blue-50' : 'bg-white'
    
    div.className = `relative px-4 py-3 border-b border-gray-100 hover:bg-gray-50 transition-colors cursor-pointer ${bgClass}`
    div.dataset.notificationId = notification.id
    
    div.innerHTML = `
      <div class="flex items-start space-x-3">
        <div class="relative flex-shrink-0">
          ${this.getNotificationIcon(notification.notification_type)}
          ${isUnread ? '<div class="absolute -bottom-1 -right-1 w-2 h-2 bg-blue-500 rounded-full"></div>' : ''}
        </div>
        
        <div class="flex-1 min-w-0">
          <div class="flex items-center justify-between mb-1">
            <p class="text-xs text-gray-500 font-medium">${notification.project_name || 'General'}</p>
            <span class="text-xs text-gray-400">${this.timeAgo(notification.created_at)}</span>
          </div>
          
          ${notification.story_name ? `
            <div class="mb-1">
              <a href="${notification.story_url || '#'}" class="text-sm font-medium text-gray-900 hover:text-blue-600 transition-colors">
                ${notification.story_name}
              </a>
            </div>
          ` : ''}
          
          <p class="text-sm text-gray-700 leading-relaxed">${notification.message}</p>
        </div>
      </div>
    `
    
    // Add click handler to mark as read
    div.addEventListener('click', () => this.markAsRead(notification.id, div))
    
    return div
  }

  getNotificationIcon(type) {
    const iconMap = {
      story_created: `<div class="w-6 h-6 bg-green-100 rounded-full flex items-center justify-center">
                       <svg class="w-3 h-3 text-green-600" fill="currentColor" viewBox="0 0 20 20">
                         <path fill-rule="evenodd" d="M10 3a1 1 0 011 1v5h5a1 1 0 110 2h-5v5a1 1 0 11-2 0v-5H4a1 1 0 110-2h5V4a1 1 0 011-1z" clip-rule="evenodd"/>
                       </svg>
                     </div>`,
      story_delivered: `<div class="w-6 h-6 bg-blue-100 rounded-full flex items-center justify-center">
                         <svg class="w-3 h-3 text-blue-600" fill="currentColor" viewBox="0 0 20 20">
                           <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/>
                         </svg>
                       </div>`,
      story_accepted: `<div class="w-6 h-6 bg-green-100 rounded-full flex items-center justify-center">
                        <svg class="w-3 h-3 text-green-600" fill="currentColor" viewBox="0 0 20 20">
                          <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
                        </svg>
                      </div>`,
      story_rejected: `<div class="w-6 h-6 bg-red-100 rounded-full flex items-center justify-center">
                        <svg class="w-3 h-3 text-red-600" fill="currentColor" viewBox="0 0 20 20">
                          <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"/>
                        </svg>
                      </div>`,
      story_assigned: `<div class="w-6 h-6 bg-yellow-100 rounded-full flex items-center justify-center">
                        <svg class="w-3 h-3 text-yellow-600" fill="currentColor" viewBox="0 0 20 20">
                          <path fill-rule="evenodd" d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z" clip-rule="evenodd"/>
                        </svg>
                      </div>`,
      comment_created: `<div class="w-6 h-6 bg-purple-100 rounded-full flex items-center justify-center">
                         <svg class="w-3 h-3 text-purple-600" fill="currentColor" viewBox="0 0 20 20">
                           <path fill-rule="evenodd" d="M18 10c0 3.866-3.582 7-8 7a8.841 8.841 0 01-4.083-.98L2 17l1.338-3.123C2.493 12.767 2 11.434 2 10c0-3.866 3.582-7 8-7s8 3.134 8 7zM7 9H5v2h2V9zm8 0h-2v2h2V9zM9 9h2v2H9V9z" clip-rule="evenodd"/>
                         </svg>
                       </div>`,
      mention_in_comment: `<div class="w-6 h-6 bg-orange-100 rounded-full flex items-center justify-center">
                            <svg class="w-3 h-3 text-orange-600" fill="currentColor" viewBox="0 0 20 20">
                              <path fill-rule="evenodd" d="M18 13V5a2 2 0 00-2-2H4a2 2 0 00-2 2v8a2 2 0 002 2h3l3 3 3-3h3a2 2 0 002-2zM5 7a1 1 0 011-1h8a1 1 0 110 2H6a1 1 0 01-1-1zm1 3a1 1 0 100 2h3a1 1 0 100-2H6z" clip-rule="evenodd"/>
                            </svg>
                          </div>`
    }
    
    return iconMap[type] || `<div class="w-6 h-6 bg-gray-100 rounded-full flex items-center justify-center">
                               <svg class="w-3 h-3 text-gray-600" fill="currentColor" viewBox="0 0 20 20">
                                 <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd"/>
                               </svg>
                             </div>`
  }

  timeAgo(dateString) {
    const date = new Date(dateString)
    const now = new Date()
    const diffInSeconds = Math.floor((now - date) / 1000)
    
    if (diffInSeconds < 60) return 'just now'
    if (diffInSeconds < 3600) return `${Math.floor(diffInSeconds / 60)}m ago`
    if (diffInSeconds < 86400) return `${Math.floor(diffInSeconds / 3600)}h ago`
    if (diffInSeconds < 604800) return `${Math.floor(diffInSeconds / 86400)}d ago`
    return date.toLocaleDateString()
  }

  toggleFilter(event) {
    event.stopPropagation()
    this.filterMenuTarget.classList.toggle('hidden')
  }

  async setFilter(event) {
    const filter = event.target.dataset.filter
    this.currentFilter = filter
    this.currentPage = 1
    
    // Update filter button text
    const filterNames = {
      all: 'All',
      unread: 'Unread',
      mentions: 'Mentions',
      stories: 'Stories'
    }
    this.filterTextTarget.textContent = filterNames[filter]
    
    // Hide filter menu
    this.filterMenuTarget.classList.add('hidden')
    
    // Show loading and reload notifications
    this.loadingTarget.classList.remove('hidden')
    this.contentTarget.classList.add('hidden')
    
    await this.loadNotifications()
  }

  async markAsRead(notificationId, element) {
    try {
      await fetch(`/notifications/${notificationId}/mark_as_read`, {
        method: 'PATCH',
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
          'Content-Type': 'application/json'
        }
      })
      
      // Update UI
      element.classList.remove('bg-blue-50')
      element.classList.add('bg-white')
      
      // Remove blue dot
      const blueDot = element.querySelector('.bg-blue-500')
      if (blueDot) {
        blueDot.remove()
      }
      
      // Update unread count
      this.unreadCount = Math.max(0, this.unreadCount - 1)
      this.updateNotificationDot()
      
    } catch (error) {
      console.error('Failed to mark notification as read:', error)
    }
  }

  async markAllAsRead() {
    try {
      await fetch('/notifications/mark_all_as_read', {
        method: 'PATCH',
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
          'Content-Type': 'application/json'
        }
      })
      
      // Update UI - remove all blue backgrounds and dots
      const unreadElements = this.notificationsListTarget.querySelectorAll('.bg-blue-50')
      unreadElements.forEach(element => {
        element.classList.remove('bg-blue-50')
        element.classList.add('bg-white')
        
        const blueDot = element.querySelector('.bg-blue-500')
        if (blueDot) {
          blueDot.remove()
        }
      })
      
      // Update unread count
      this.unreadCount = 0
      this.updateNotificationDot()
      
    } catch (error) {
      console.error('Failed to mark all notifications as read:', error)
    }
  }

  async loadMore() {
    this.currentPage += 1
    this.loadMoreButtonTarget.textContent = 'Loading...'
    this.loadMoreButtonTarget.disabled = true
    
    await this.loadNotifications(this.currentPage)
    
    this.loadMoreButtonTarget.textContent = 'Load more notifications'
    this.loadMoreButtonTarget.disabled = false
  }

  updateLoadMoreButton(hasMore, nextPage) {
    if (hasMore) {
      this.loadMoreContainerTarget.classList.remove('hidden')
      this.currentPage = nextPage - 1
    } else {
      this.loadMoreContainerTarget.classList.add('hidden')
    }
  }

  showError() {
    this.loadingTarget.classList.add('hidden')
    this.contentTarget.classList.remove('hidden')
    this.notificationsListTarget.innerHTML = `
      <div class="p-8 text-center">
        <div class="text-red-400 mb-2">
          <svg class="w-8 h-8 mx-auto" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clip-rule="evenodd"/>
          </svg>
        </div>
        <div class="text-sm text-gray-500">Failed to load notifications</div>
        <button class="mt-2 text-xs text-blue-600 hover:text-blue-800" onclick="location.reload()">
          Try again
        </button>
      </div>
    `
  }
}
