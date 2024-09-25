import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="modal"
export default class extends Controller {
  static targets = ['modal', 'backdrop'];
  static classes = ['hideModal', 'showModal', 'hideBackdrop', 'showBackdrop'];

  connect() {
    this.closeAllModals();
    this.resetTimeout = null;

    document.documentElement.addEventListener('turbo:submit-end', (event) => {
      if (event.detail.success) this.closeAllModals();
    });
  }

  closeAllModals() {
    this.modalTargets.forEach((modal) => this.closeById(modal.id));
  }

  open(event) {
    const modalId = event.currentTarget.dataset.modalId;
    this.openById(modalId);
  }

  close(event) {
    const modalId = event.currentTarget.dataset.modalId;
    this.closeById(modalId);
  }

  openById(modalId) {
    const modal = this.element.querySelector(`#${modalId}`);
    const backdrop = this.element.querySelector(
      `[data-modal-id="${modalId}"][data-modal-target="backdrop"]`
    );

    if (modal && backdrop) {
      backdrop.classList.add(...this.showBackdropClasses);
      backdrop.classList.remove(...this.hideBackdropClasses);
      modal.classList.add(...this.showModalClasses);
      modal.classList.remove(...this.hideModalClasses);
    }

    if (this.resetTimeout) {
      clearTimeout(this.resetTimeout);
      this.resetTimeout = null;
    }
  }

  closeById(modalId) {
    const modal = this.element.querySelector(`#${modalId}`);
    const backdrop = this.element.querySelector(
      `[data-modal-id="${modalId}"][data-modal-target="backdrop"]`
    );

    if (modal && backdrop) {
      backdrop.classList.remove(...this.showBackdropClasses);
      backdrop.classList.add(...this.hideBackdropClasses);
      modal.classList.remove(...this.showModalClasses);
      modal.classList.add(...this.hideModalClasses);

      const forms = modal.querySelectorAll('form');
      if (forms.length > 0) {
        this.resetTimeout = setTimeout(() => {
          forms.forEach((form) => form.reset());
        }, 10000);
      }
    }
  }

  backdropClose(event) {
    if (event.target === event.currentTarget) this.close(event);
  }
}
