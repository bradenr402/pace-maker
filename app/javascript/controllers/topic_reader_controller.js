import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="topic-reader"
export default class extends Controller {
  static values = { updateLastReadPath: String };

  connect() {
    console.log(this.updateLastReadPathValue);

    this.observer = new MutationObserver(() => this.updateLastRead());
    this.observeMessagesContainer();
  }

  observeMessagesContainer() {
    const messagesContainer = document.querySelector('#messages'); // Adjust this selector
    if (!messagesContainer) {
      console.warn('Messages container not found!');
      return;
    }

    this.observer.observe(messagesContainer, { childList: true, subtree: true });
  }

  updateLastRead() {
    fetch(this.updateLastReadPathValue, {
      method: 'POST',
      headers: {
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({}),
    });
  }

  disconnect() {
    this.observer.disconnect();
  }
}
