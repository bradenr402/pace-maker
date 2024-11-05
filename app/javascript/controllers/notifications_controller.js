import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="notifications"
export default class extends Controller {
  static targets = ['notification'];
  static values = { duration: { type: Number, default: 10000 } };
  static classes = ['hidden', 'visible', 'exit'];

  connect() {
    this.showNotifications();
  }

  showNotifications() {
    this.notificationTargets.forEach((notification, index) => {
      notification.classList.add(this.hiddenClass);

      setTimeout(() => {
        notification.classList.remove(this.hiddenClass);
        notification.classList.add(this.visibleClass);
      }, 100 + index * 500);

      setTimeout(() => {
        this.hideNotification(notification);
      }, this.durationValue + index * 500);
    });
  }

  close(event) {
    const notification = event.currentTarget.closest(
      '[data-notifications-target="notification"]'
    );
    this.hideNotification(notification);
  }

  hideNotification(notification) {
    notification.classList.remove(this.visibleClass);
    notification.classList.add(this.exitClass);

    setTimeout(() => {
      notification.remove();
    }, 350);
  }
}
