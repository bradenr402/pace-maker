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
        const tempDiv = document.createElement('div');
        tempDiv.innerHTML = data.html;

        const dateMarkers = tempDiv.querySelectorAll('[data-date]');

        dateMarkers.forEach((marker) => {
          const date = marker.dataset.date;

          const existingMarker = this.messagesTarget.querySelector(`[data-date="${date}"]`);

          if (existingMarker && tempDiv.querySelector(`[data-date="${date}"]`)) {
            existingMarker.remove();
          }
        });

        this.messagesTarget.insertAdjacentHTML('afterbegin', tempDiv.innerHTML);
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

    element.scrollIntoView({ behavior: 'smooth' });

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
