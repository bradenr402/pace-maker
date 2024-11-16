// app/javascript/controllers/theme_controller.js
import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="theme"
export default class extends Controller {
  static targets = ['input'];
  static values = { userTheme: String };

  connect() {
    this.applyTheme();
    this.setupSystemThemeListener();
  }

  setupSystemThemeListener() {
    this.systemThemeMediaQuery = window.matchMedia('(prefers-color-scheme: dark)');
    this.systemThemeMediaQuery.addEventListener('change', () => this.applyTheme());
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

    // Set meta tag for mobile status bar color
    const metaThemeColor =
      document.querySelector('meta[name="theme-color"]') || document.createElement('meta');
    metaThemeColor.name = 'theme-color';
    metaThemeColor.content = isDarkTheme ? '#0f172a' : '#f8fafc';
    if (!document.querySelector('meta[name="theme-color"]')) {
      document.head.appendChild(metaThemeColor);
    }
  }
}
