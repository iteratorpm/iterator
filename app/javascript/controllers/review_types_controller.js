import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["nameDisplay"]

  editName(event) {
    const id = event.currentTarget.dataset.id
    const nameElement = document.querySelector(`.review-type-name[data-id="${id}"]`)
    const currentName = nameElement.textContent

    // Create form
    const form = document.createElement('form')
    form.className = 'inline-form'
    form.innerHTML = `
      <input type="text" value="${currentName}" class="border border-gray-300 rounded p-1 mr-2" maxlength="25">
      <button type="submit" class="bg-blue-600 text-white px-2 py-1 rounded text-sm">Save</button>
      <button type="button" class="cancel-edit ml-1 text-gray-600 px-2 py-1 rounded text-sm">Cancel</button>
    `

    // Replace name with form
    nameElement.replaceWith(form)
    form.querySelector('input').focus()

    // Handle submit
    form.addEventListener('submit', (e) => {
      e.preventDefault()
      const newName = e.target.querySelector('input').value.trim()
      this.saveName(id, newName, nameElement)
    })

    // Handle cancel
    form.querySelector('.cancel-edit').addEventListener('click', () => {
      form.replaceWith(nameElement)
    })
  }

  saveName(id, newName, nameElement) {
    const url = `/projects/${this.element.dataset.projectId}/review_types/${id}`
    const csrfToken = document.querySelector("[name='csrf-token']").content

    fetch(url, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken,
        'Accept': 'application/json'
      },
      body: JSON.stringify({ review_type: { name: newName } })
    })
    .then(response => response.json())
    .then(data => {
      if (data.status === 'success') {
        nameElement.textContent = data.name
        document.querySelector('.inline-form').replaceWith(nameElement)
      } else {
        alert(data.errors.join(', '))
      }
    })
    .catch(error => {
      console.error('Error:', error)
      alert('Failed to update review type')
    })
  }
}
