import { Controller } from "@hotwired/stimulus"
import Tribute from "tributejs"

export default class extends Controller {
  static targets = ["input"]

  connect() {
    // Get data from window object
    const { users, stories } = window.autocompleteData || {};
    this.projectUrl = window.location.href.split('#')[0]; // Get current project URL
    
    this.tribute = new Tribute({
      collection: [
        this.userMentionConfig(users || []),
        this.storyMentionConfig(stories || [])
      ]
    })

    this.inputTargets.forEach(target => {
      if (!target.dataset.tributeAttached) {
        this.tribute.attach(target)
        target.dataset.tributeAttached = "true"
      }
    })

    this.patchTurboCompat()
  }

  userMentionConfig(users) {
    return {
      trigger: "@",
      values: users.map(user => ({ 
        name: user[0],  // First element is name
        username: user[1]  // Second element is username
      })),
      lookup: 'name',
      menuItemTemplate: item => `<strong>${item.original.name}</strong> (${item.original.username})`,
      selectTemplate: item => `@${item.original.username}`
    }
  }

  storyMentionConfig(stories) {
    return {
      trigger: "#",
      requireLeadingSpace: true,
      values: stories.map(story => ({
        project_story_id: story[0],  // First element is ID
        name: story[1]  // Second element is name
      })),
      lookup: 'name',
      menuItemTemplate: item => `<strong>#${item.original.project_story_id}</strong> ${item.original.name}`,
      selectTemplate: item => `${this.projectUrl}#story-${item.original.project_story_id}`
    }
  }

  patchTurboCompat() {
    // Prevent Turbo from removing menu between frame updates
    const originalCreateMenu = this.tribute.createMenu
    this.tribute.createMenu = function (...args) {
      const menu = originalCreateMenu.apply(this, args)
      menu.dataset.turboPermanent = "true"
      return menu
    }
  }

  // Cleanup when controller is disconnected
  disconnect() {
    if (this.tribute) {
      this.inputTargets.forEach(target => {
        this.tribute.detach(target)
        target.removeAttribute('data-tribute-attached')
      })
    }
  }
}
