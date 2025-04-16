import { Controller } from "@hotwired/stimulus"
import * as Turbo from "@hotwired/turbo-rails"

export default class extends Controller {
  static targets = ["editForm", "saveButton", "cancelButton", "editButton", "avatarInput", "avatarPreview", "avatarImage"]

  connect() {
    // Initialize any default behavior
  }

  // Toggle edit mode for general profile
  toggleEdit(e) {
    e.preventDefault()
    this.editFormTargets.forEach(form => form.classList.toggle("hidden"))
    this.editButtonTargets.forEach(button => button.classList.toggle("hidden"))
    this.saveButtonTargets.forEach(button => button.classList.toggle("hidden"))
    this.cancelButtonTargets.forEach(button => button.classList.toggle("hidden"))
  }

  // Handle avatar upload
  uploadAvatar(e) {
    e.preventDefault()
    this.avatarInputTarget.click()
  }

  // Preview avatar before upload
  previewAvatar() {
    const file = this.avatarInputTarget.files[0]
    if (file) {
      const reader = new FileReader()
      reader.onload = (e) => {
        this.avatarPreviewTarget.src = e.target.result
        this.avatarPreviewTarget.classList.remove("hidden")
        this.submitAvatar(file)
      }
      reader.readAsDataURL(file)
    }
  }

  // Submit avatar via Turbo Streams
  async submitAvatar(file) {
    const formData = new FormData()
    formData.append("user[avatar]", file)

    try {
      const response = await fetch("/profile/avatar", {
        method: "POST",
        body: formData,
        headers: {
          "Accept": "text/vnd.turbo-stream.html, text/html, application/xhtml+xml",
          "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
        }
      })

      if (response.ok) {
        const html = await response.text()
        Turbo.renderStreamMessage(html)
      }
    } catch (error) {
      console.error("Error uploading avatar:", error)
    }
  }

  // Show password change modal
  showPasswordModal(e) {
    e.preventDefault()
    this.dispatch("showPasswordModal", { detail: { url: "/profile" } })
  }

  // Save profile changes via Turbo Streams
  async saveProfile(e) {
    e.preventDefault()
    const form = this.editFormTarget
    const formData = new FormData(form)

    try {
      const response = await fetch(form.action, {
        method: "PATCH",
        body: formData,
        headers: {
          "Accept": "text/vnd.turbo-stream.html, text/html, application/xhtml+xml",
          "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
        }
      })

      if (response.ok) {
        const html = await response.text()
        Turbo.renderStreamMessage(html)
        this.toggleEdit(e) // Exit edit mode
      }
    } catch (error) {
      console.error("Error saving profile:", error)
    }
  }

  showToken(e) {
    // The Turbo Stream response will handle showing the token
  }

  hideToken(e) {
    // The Turbo Stream response will handle hiding the token
  }

  copyToken(e) {
    e.preventDefault()
    const tokenElement = document.getElementById('api_token_value')
    if (tokenElement) {
      navigator.clipboard.writeText(tokenElement.textContent.trim())
        .then(() => {
          const originalText = e.target.innerHTML
          e.target.innerHTML = 'Copied!'
          setTimeout(() => {
            e.target.innerHTML = originalText
          }, 2000)
        })
        .catch(err => {
          console.error('Failed to copy token: ', err)
        })
    }
  }
}
