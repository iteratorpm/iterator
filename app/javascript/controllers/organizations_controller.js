import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["organizationSection", "newOrganizationForm", "newOrganizationName", "submitButton"]

  showNewOrganizationForm(event) {
    event.preventDefault();
    this.organizationSectionTarget.classList.add('hidden');
    this.newOrganizationFormTarget.classList.remove('hidden');
    this.submitButtonTarget.disabled = true;
  }

  hideNewOrganizationForm(event) {
    event.preventDefault();
    this.organizationSectionTarget.classList.remove('hidden');
    this.newOrganizationFormTarget.classList.add('hidden');
    this.submitButtonTarget.disabled = false;
  }

  createOrganization(event) {
    event.preventDefault();
    const orgName = this.newOrganizationNameTarget.value.trim();

    if (orgName === '') {
      alert('Please enter an organization name');
      return;
    }

    // Create organization via AJAX
    fetch('/organizations', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
      },
      body: JSON.stringify({ organization: { name: orgName } })
    })
      .then(response => response.json())
      .then(data => {
        if (data.id) {
          // Add new org to select and select it
          const select = document.querySelector('#project_organization_id');
          if (select) {
            const option = new Option(orgName, data.id, true, true);
            select.add(option);
            select.dispatchEvent(new Event('change'));
          } else {
            // Create new select if it didn't exist before
            const organizationSection = this.organizationSectionTarget;
            organizationSection.innerHTML = `
                <select name="project[organization_id]" id="project_organization_id" class="w-full p-3 border border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500" required>
                  <option value="${data.id}" selected>${orgName}</option>
                </select>
              `;
          }

          // Hide new org form and show select
          this.hideNewOrganizationForm(event);

        } else {
          alert('Error creating organization: ' + (data.errors || 'Unknown error'));
        }
      })
      .catch(error => {
        console.error('Error:', error);
        alert('Error creating organization');
      });
  }

  checkSelection(event) {
    this.submitButtonTarget.disabled = event.target.value === '';
  }
}
