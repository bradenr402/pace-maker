import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="typing"
export default class extends Controller {
  static targets = ['input'];
  static values = { userId: Number, typingPath: String };

  connect() {
    this.typingTimeout = null;

    this.inputTarget.addEventListener('input', this.debounce(this.broadcastTyping.bind(this), 500));
    this.inputTarget.addEventListener('blur-sm', () => this.stopTyping());

    window.addEventListener('beforeunload', () => this.stopTyping());
  }

  debounce(func, delay) {
    let timeout;
    return (...args) => {
      clearTimeout(timeout);
      timeout = setTimeout(() => func.apply(this, args), delay);
    };
  }

  broadcastTyping() {
    const message = this.inputTarget.value.trim();

    if (message.length > 0) this.sendTypingStatus(true);
    else this.sendTypingStatus(false);
  }

  stopTyping() {
    this.sendTypingStatus(false);
  }

  sendTypingStatus(isTyping) {
    fetch(this.typingPathValue, {
      method: 'POST',
      headers: {
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ user_id: this.userIdValue, typing: isTyping }),
    });

    if (isTyping) {
      clearTimeout(this.typingTimeout);
      this.typingTimeout = setTimeout(() => this.sendTypingStatus(false), 30000);
    }
  }
}
