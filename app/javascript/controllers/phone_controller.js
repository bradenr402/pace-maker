import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="phone"
export default class extends Controller {
  static targets = ['phone', 'countryCode'];

  connect() {
    this.updateCountryCode();
    this.shouldFormat = true;

    this.phoneFormat();
  }

  updateCountryCode(event) {
    this.countryCode = this.countryCodeTarget.value;
  }

  toggleFormatting(event) {
    this.shouldFormat = event.target.checked;
    this.phoneFormat();
  }

  phoneFormat(event) {
    const input = this.phoneTarget.value;
    this.phoneTarget.value = this.formatPhone(input);
  }

  stripPhone(input) {
    return input.replace(/\D/g, ''); // Remove non-digit characters
  }

  formatPhone(input) {
    if (!this.shouldFormat) return this.stripPhone(input);

    const phoneDigits = input.replace(/\D/g, ''); // Remove non-digit characters

    switch (this.countryCode) {
      case 'US':
      case 'CA':
        return this.formatUSPhone(phoneDigits);
      case 'GB':
        return this.formatUKPhone(phoneDigits);
      case 'AU':
        return this.formatAUSPhone(phoneDigits);
      default:
        return this.generalFormat(phoneDigits);
    }
  }

  formatUSPhone(phoneDigits) {
    // Format: (###) ###-####
    const match = phoneDigits.match(/(\d{0,3})(\d{0,3})(\d{0,4})/);
    if (!match) return phoneDigits;

    const [, areaCode, prefix, lineNumber] = match;
    if (prefix && lineNumber) return `(${areaCode}) ${prefix}-${lineNumber}`;
    if (prefix) return `(${areaCode}) ${prefix}`;
    return areaCode;
  }

  formatUKPhone(phoneDigits) {
    // Format: #### ### ###
    const match = phoneDigits.match(/(\d{0,4})(\d{0,3})(\d{0,3})/);
    if (!match) return phoneDigits;

    const [, areaCode, firstPart, secondPart] = match;
    if (firstPart && secondPart) return `${areaCode} ${firstPart} ${secondPart}`;
    if (firstPart) return `${areaCode} ${firstPart}`;
    return areaCode;
  }

  formatAUSPhone(phoneDigits) {
    // Format: # #### ####
    const match = phoneDigits.match(/(\d{0,1})(\d{0,4})(\d{0,4})/);
    if (!match) return phoneDigits;

    const [, areaCode, firstPart, secondPart] = match;
    if (firstPart && secondPart) return `${areaCode} ${firstPart} ${secondPart}`;
    if (firstPart) return `${areaCode} ${firstPart}`;
    return areaCode;
  }

  generalFormat(phoneDigits) {
    // General Format: ### ### ###
    const match = phoneDigits.match(/(\d{0,3})(\d{0,3})(\d{0,4})/);
    if (!match) return phoneDigits;

    const [, firstPart, secondPart, thirdPart] = match;
    if (secondPart && thirdPart) return `${firstPart} ${secondPart} ${thirdPart}`;
    if (secondPart) return `${firstPart} ${secondPart}`;
    return firstPart;
  }
}
