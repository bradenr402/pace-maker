import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="reply-message"
export default class extends Controller {
  static targets = ['parent', 'replyMessage', 'messageUserName', 'messageContent', 'input'];

  connect() {
    if (this.parentTarget.value) {
      const button = document.querySelector(`[data-message-id="${this.parentTarget.value}"]`);
      button.click();
    }
  }

  reply(event) {
    const button = event.currentTarget;
    const messageId = button.dataset.messageId;

    this.parentTarget.value = messageId;
    this.replyMessageTarget.classList.remove('hidden');
    this.messageUserNameTarget.textContent = button.dataset.messageUserName;
    this.messageContentTarget.textContent = button.dataset.messageContent;
    this.inputTarget.focus();
  }

  cancel() {
    this.parentTarget.value = '';
    this.replyMessageTarget.classList.add('hidden');
    this.messageUserNameTarget.textContent = '';
    this.messageContentTarget.textContent = '';
    this.inputTarget.focus();
  }
}
