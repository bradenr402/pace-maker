import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="pagination"
export default class extends Controller {
  static targets = ['container', 'button', 'spinner'];
  static values = { loadMorePath: String, insertion: { type: String, default: 'afterbegin' } };

  connect() {
    this.scrollToUnread();
  }

  loadMore(event) {
    event.preventDefault();

    this.hideButton();
    this.showSpinner();

    const url = new URL(this.loadMorePathValue, window.location.origin);
    url.searchParams.set('oldest_timestamp', this.containerTarget.dataset.oldestTimestamp);

    fetch(url.toString(), {
      headers: {
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
        'Content-Type': 'application/json',
      },
    })
      .then((response) => response.json())
      .then((data) => {
        const tempDiv = document.createElement('div');
        tempDiv.innerHTML = data.html;

        const dateMarkers = tempDiv.querySelectorAll('[data-date]');

        dateMarkers.forEach((marker) => {
          const date = marker.dataset.date;

          const existingMarker = this.containerTarget.querySelector(`[data-date="${date}"]`);

          if (existingMarker && tempDiv.querySelector(`[data-date="${date}"]`)) {
            existingMarker.remove();
          }
        });

        this.containerTarget.insertAdjacentHTML(this.insertionValue, tempDiv.innerHTML);
        this.containerTarget.dataset.oldestTimestamp = data.oldest_timestamp;

        if (data.more_data) {
          this.showButton();
          this.hideSpinner();
        } else {
          this.buttonTarget.remove();
          this.spinnerTarget.remove();
        }
      });
  }

  scrollToUnread() {
    const form = document.getElementById('new_message_form');
    const unreadBanner = document.getElementById('unread_banner');
    const offset = 50;

    if (unreadBanner) {
      unreadBanner.scrollIntoView({ behavior: 'smooth', block: 'center' });
      window.scrollBy(0, -offset);
    } else if (form) {
      form.scrollIntoView({ behavior: 'smooth' });
      window.scrollBy(0, -offset);
    }
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
