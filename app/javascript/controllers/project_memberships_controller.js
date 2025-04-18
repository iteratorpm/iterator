import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["inviteModal", "searchInput", "inviteButton"]

  connect() {
    // Initialize modal
    this.inviteModal = document.getElementById('invite-modal');
    this.searchInput = document.getElementById('invite-modal-search-bar');
    this.inviteButton = document.getElementById('invite--0--button');
    
    // Setup event listeners
    document.getElementById('invite-people-button').addEventListener('click', this.openModal.bind(this));
    document.getElementById('cancel-button').addEventListener('click', this.closeModal.bind(this));
    this.searchInput.addEventListener('input', this.updateInviteButton.bind(this));
  }

  openModal() {
    this.inviteModal.style.display = 'flex';
    this.searchInput.focus();
  }

  closeModal() {
    this.inviteModal.style.display = 'none';
  }

  updateInviteButton() {
    const emails = this.searchInput.value.split(/[\s,]+/).filter(email => email.length > 0);
    const count = emails.length;
    
    if (count > 0) {
      this.inviteButton.disabled = false;
      this.inviteButton.classList.remove('button--disabled');
      this.inviteButton.textContent = `Invite (${count})`;
    } else {
      this.inviteButton.disabled = true;
      this.inviteButton.classList.add('button--disabled');
      this.inviteButton.textContent = 'Invite (0)';
    }
  }
}
