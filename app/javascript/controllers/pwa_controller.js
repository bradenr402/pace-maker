import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="pwa"
export default class extends Controller {
  static targets = [
    'chromeInstructions',
    'edgeInstructions',
    'firefoxInstructions',
    'iosSafariInstructions',
    'macosSafariInstructions',
    'unknownInstructions',
    'browserSelect',
    'installedMessage',
    'instructionsContainer',
  ];

  connect() {
    if (this.isAppInstalled()) this.showInstalledMessage();
    else this.showInstructions();
  }

  isAppInstalled() {
    return window.matchMedia('(display-mode: standalone)').matches;
  }

  showInstalledMessage() {
    this.installedMessageTarget.classList.remove('hidden');
    this.instructionsContainerTarget.classList.add('hidden');
  }

  hideAllInstructions() {
    this.chromeInstructionsTarget.classList.add('hidden');
    this.edgeInstructionsTarget.classList.add('hidden');
    this.firefoxInstructionsTarget.classList.add('hidden');
    this.iosSafariInstructionsTarget.classList.add('hidden');
    this.macosSafariInstructionsTarget.classList.add('hidden');
    this.unknownInstructionsTarget.classList.add('hidden');
  }

  showInstructions() {
    this.hideAllInstructions();
    const userAgent = navigator.userAgent;

    if (this.isChrome(userAgent)) {
      this.makeVisible(this.chromeInstructionsTarget);
      this.browserSelectTarget.value = 'chrome';
    } else if (this.isEdge(userAgent)) {
      this.makeVisible(this.edgeInstructionsTarget);
      this.browserSelectTarget.value = 'edge';
    } else if (this.isFirefox(userAgent)) {
      this.makeVisible(this.firefoxInstructionsTarget);
      this.browserSelectTarget.value = 'firefox';
    } else if (this.isSafari(userAgent)) {
      const platform = navigator.platform;

      if (this.isIOS(platform)) {
        this.makeVisible(this.iosSafariInstructionsTarget);
        this.browserSelectTarget.value = 'iosSafari';
      } else {
        this.makeVisible(this.macosSafariInstructionsTarget);
        this.browserSelectTarget.value = 'macosSafari';
      }
    } else {
      this.makeVisible(this.unknownInstructionsTarget);
    }
  }

  isChrome(userAgent) {
    return /chrome/i.test(userAgent) && !/edg/i.test(userAgent);
  }

  isEdge(userAgent) {
    return /edg/i.test(userAgent);
  }

  isFirefox(userAgent) {
    return /firefox/i.test(userAgent);
  }

  isSafari(userAgent) {
    return /safari/i.test(userAgent) && !/chrome/i.test(userAgent);
  }

  isIOS(platform) {
    return /iPhone|iPad|iPod/.test(platform);
  }

  makeVisible(target) {
    target.classList.remove('hidden');
  }

  manualSelect(event) {
    const selectedValue = event.target.value;
    this.hideAllInstructions();

    switch (selectedValue) {
      case 'chrome':
        this.makeVisible(this.chromeInstructionsTarget);
        break;
      case 'edge':
        this.makeVisible(this.edgeInstructionsTarget);
        break;
      case 'firefox':
        this.makeVisible(this.firefoxInstructionsTarget);
        break;
      case 'iosSafari':
        this.makeVisible(this.iosSafariInstructionsTarget);
        break;
      case 'macosSafari':
        this.makeVisible(this.macosSafariInstructionsTarget);
        break;
      default:
        break;
    }
  }
}
