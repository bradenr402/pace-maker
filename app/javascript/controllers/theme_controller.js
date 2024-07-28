// app/javascript/controllers/theme_controller.js
import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="theme"
export default class extends Controller {
  static targets = ['themeSelect'];

  applyTheme() {
    const theme = this.themeSelectTarget.value || 'system';
    this.setTheme(theme);
  }

  change(event) {
    const theme = event.target.value;
    this.setTheme(theme);
  }

  setTheme(theme) {
    if (theme === 'dark') {
      document.documentElement.classList.add('dark');
      document.documentElement.classList.remove('light');
    } else if (theme === 'light') {
      document.documentElement.classList.add('light');
      document.documentElement.classList.remove('dark');
    } else {
      // Remove both to fall back to system preference
      document.documentElement.classList.remove('dark', 'light');
      if (window.matchMedia('(prefers-color-scheme: dark)').matches) {
        document.documentElement.classList.add('dark');
      }
    }
  }
}
