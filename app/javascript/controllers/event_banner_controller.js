import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="event-banner"
export default class extends Controller {
  static targets = ['banner'];

  connect() {
    this.bannerTargets.forEach((banner) => {
      if (this.isBannerDismissed(banner)) this.hide(banner);
      else this.show(banner);
    });
  }

  getEventId(element) {
    return element.dataset.eventId;
  }

  show(banner) {
    banner.classList.remove('hidden');
  }

  hide(banner) {
    banner.classList.add('hidden');
  }

  dismiss(event) {
    const button = event.target.closest('button');

    const banner = this.bannerTargets.find(
      (banner) => this.getEventId(banner) === this.getEventId(button),
    );

    if (banner) {
      this.setBannerDismissed(banner);
      this.hide(banner);
    }
  }

  isBannerDismissed(banner) {
    const eventId = this.getEventId(banner);

    return document.cookie
      .split(';')
      .some((cookie) => cookie.trim().startsWith(`event_banner_${eventId}_dismissed=`));
  }

  setBannerDismissed(banner) {
    const eventId = this.getEventId(banner);
    const expiresIn = Math.max(0, banner.dataset.cookieExpiresIn);

    document.cookie = `event_banner_${eventId}_dismissed=true; path=/; max-age=${expiresIn}`;
  }
}
