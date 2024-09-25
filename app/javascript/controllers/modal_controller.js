import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="modal"
export default class extends Controller {
  static targets = ['modal', 'backdrop'];
  static classes = ['hideModal', 'showModal', 'hideBackdrop', 'showBackdrop'];

  connect() {
    this.modalTargets.forEach((modal) => {
      modal.classList.add(...this.hideModalClasses);
      modal.classList.remove(...this.showModalClasses);
    });
  }

  open(event) {
    event.preventDefault();
    const modalId = event.currentTarget.dataset.modalId;
    const modal = document.getElementById(modalId);
    const backdrop = document.querySelector(
      `[data-modal-id="${modalId}"][data-modal-target="backdrop"]`
    );

    if (modal && backdrop) {
      backdrop.classList.add(...this.showBackdropClasses);
      backdrop.classList.remove(...this.hideBackdropClasses);
      modal.classList.add(...this.showModalClasses);
      modal.classList.remove(...this.hideModalClasses);
    }
  }

  close(event) {
    event.preventDefault();
    const modalId = event.currentTarget.dataset.modalId;
    const modal = document.getElementById(modalId);
    const backdrop = document.querySelector(
      `[data-modal-id="${modalId}"][data-modal-target="backdrop"]`
    );

    if (modal && backdrop) {
      backdrop.classList.remove(...this.showBackdropClasses);
      backdrop.classList.add(...this.hideBackdropClasses);
      modal.classList.remove(...this.showModalClasses);
      modal.classList.add(...this.hideModalClasses);
    }
  }

  backdropClose(event) {
    if (event.target === event.currentTarget) this.close(event);
  }
}
