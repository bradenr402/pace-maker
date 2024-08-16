// app/javascript/controllers/theme_controller.js
import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="theme"
export default class extends Controller {
  static targets = ['themeSelect'];
  static values = { userTheme: String };

  connect() {
    this.setTheme(this.userThemeValue);
  }

  applyTheme() {
    let theme;
    if (this.hasThemeSelectTarget) {
      theme = this.themeSelectTarget.value;
    } else {
      theme = this.userThemeValue;
    }

    this.setTheme(theme);
  }

  change(event) {
    const theme = event.target.value;
    this.setTheme(theme);
  }

  setTheme(theme) {
    if (theme === 'dark') {
      document.documentElement.classList.add('dark');
    } else if (theme === 'light') {
      document.documentElement.classList.remove('dark');
    } else if (window.matchMedia('(prefers-color-scheme: dark)').matches) {
      document.documentElement.classList.add('dark');
    }
  }
}
