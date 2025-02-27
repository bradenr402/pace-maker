import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="pagination"
export default class extends Controller {
  static targets = ['messages', 'button', 'spinner'];
  static values = { loadMorePath: String };

  connect() {
    this.scrollToBottom();
  }

  loadMore(event) {
    event.preventDefault();

    this.hideButton();
    this.showSpinner();

    const url = new URL(this.loadMorePathValue, window.location.origin);
    url.searchParams.set('oldest_message_timestamp', this.messagesTarget.dataset.oldestTimestamp);

    fetch(url.toString())
      .then((response) => response.json())
      .then((data) => {
        this.messagesTarget.insertAdjacentHTML('afterbegin', data.html);
        this.messagesTarget.dataset.oldestTimestamp = data.oldest_timestamp;

        if (data.more_messages) {
          this.showButton();
          this.hideSpinner();
        } else {
          this.buttonTarget.remove();
          this.spinnerTarget.remove();
        }
      });
  }

  scrollToBottom() {
    const element = document.getElementById('new_message_form');
    const offset = 50;

    element.scrollIntoView({
      behavior: 'smooth',
      block: 'start',
    });

    window.scrollBy(0, -offset);
  }

  showButton() {
    this.buttonTarget.classList.remove('hidden');
  }

  showSpinner() {
    this.spinnerTarget.classList.remove('hidden');
  }

  hideButton() {
    this.buttonTarget.classList.add('hidden');
  }

  hideSpinner() {
    this.spinnerTarget.classList.add('hidden');
  }
}
