// app/javascript/controllers/theme_controller.js
import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="theme"
export default class extends Controller {
  static targets = ['input'];
  static values = { userTheme: String };

  connect() {
    this.applyTheme();
  }

  applyTheme() {
    let theme;

    this.inputTargets.forEach((input) => {
      if (input.checked) theme = input.value;
    });

    if (!theme) theme = this.userThemeValue;

    this.setTheme(theme);
  }

  change(event) {
    const theme = event.target.value;
    this.setTheme(theme);
  }

  setTheme(theme) {
    const isDarkTheme = theme === 'dark' || (theme === 'system' && window.matchMedia('(prefers-color-scheme: dark)').matches);

    if (isDarkTheme) {
      document.documentElement.classList.add('dark');
    } else {
      document.documentElement.classList.remove('dark');
    }
  }
}
