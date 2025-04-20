import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "newWebhookUrl",
    "newWebhookError",
    "webhookItem",
    "webhookUrl",
    "editWebhookUrl",
    "webhookId",
    "form",
    "errorDetails",
    "errorToggleIcon"
  ]

  addWebhook() {
    const url = this.newWebhookUrlTarget.value.trim()
    if (!url) return

    fetch(this.formTarget.action, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector("[name='csrf-token']").content,
        'Accept': 'application/json'
      },
      body: JSON.stringify({ webhook: { webhook_url: url } })
    })
    .then(response => {
      if (response.ok) {
        window.location.reload()
      } else {
        this.showError()
      }
    })
    .catch(() => this.showError())
  }

  editWebhook(event) {
    const item = event.target.closest('[data-webhooks-target="webhookItem"]')
    const id = item.dataset.webhookId
    const url = item.querySelector('[data-webhooks-target="webhookUrl"]').textContent

    this.webhookIdTarget.value = id
    this.editWebhookUrlTarget.value = url

    // Hide all other forms first
    this.webhookItemTargets.forEach(el => {
      if (el !== item) el.querySelector('form')?.classList.add('hidden')
    })

    // Create or show form
    let form = item.querySelector('form')
    if (!form) {
      form = this.formTarget.cloneNode(true)
      form.classList.remove('hidden')
      item.appendChild(form)
    } else {
      form.classList.toggle('hidden')
    }
  }

  deleteWebhook(event) {
    if (!confirm('Are you sure you want to delete this webhook?')) return

    const item = event.target.closest('[data-webhooks-target="webhookItem"]')
    const id = item.dataset.webhookId

    fetch(`${this.formTarget.action}/${id}`, {
      method: 'DELETE',
      headers: {
        'X-CSRF-Token': document.querySelector("[name='csrf-token']").content
      }
    })
    .then(response => {
      if (response.ok) {
        item.remove()
      } else {
        alert('Failed to delete webhook')
      }
    })
  }

  toggleWebhook(event) {
    const item = event.target.closest('[data-webhooks-target="webhookItem"]')
    const id = item.dataset.webhookId
    const enabled = event.target.checked

    fetch(`${this.formTarget.action}/${id}/toggle`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector("[name='csrf-token']").content
      },
      body: JSON.stringify({ enabled: enabled })
    })
    .then(response => {
      if (!response.ok) {
        event.target.checked = !enabled
        alert('Failed to update webhook status')
      }
    })
  }

  toggleErrorDetails(event) {
    const container = event.currentTarget.closest('.border-t')
    const details = container.querySelector('[data-webhooks-target="errorDetails"]')
    const icon = container.querySelector('[data-webhooks-target="errorToggleIcon"]')

    details.classList.toggle('hidden')
    icon.classList.toggle('rotate-180')
  }

  showError() {
    this.newWebhookErrorTarget.classList.remove('hidden')
    setTimeout(() => {
      this.newWebhookErrorTarget.classList.add('hidden')
    }, 3000)
  }
}
