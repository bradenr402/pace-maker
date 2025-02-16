import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="pwa-banner"
export default class extends Controller {
  static values = { dismissed: Boolean };
  static targets = ['banner'];

  connect() {
    if (this.isBannerDismissed() || !this.isPwaSupported() || this.isAppInstalled()) this.hide();
    else this.show();
  }

  show() {
    this.bannerTarget.classList.remove('hidden');
  }

  hide() {
    this.bannerTarget.classList.add('hidden');
  }

  dismiss() {
    this.setBannerDismissed();
    this.hide();
  }

  isPwaSupported() {
    return 'serviceWorker' in navigator;
  }

  isAppInstalled() {
    return window.matchMedia('(display-mode: standalone)').matches;
  }

  isBannerDismissed() {
    return document.cookie
      .split(';')
      .some((cookie) => cookie.trim().startsWith('pwa_banner_dismissed='));
  }

  setBannerDismissed() {
    const expiresIn = 60 * 60 * 24 * 10; // 10 days
    document.cookie = `pwa_banner_dismissed=true; path=/; max-age=${expiresIn}`;
  }
}
