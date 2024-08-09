import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="restore-defaults"
export default class extends Controller {
  static targets = [
    'emailVisible',
    'phoneVisible',
    'theme',
    'inApp',
    'requireGender',
    'maxAllowedRequests',
    'longRunDistanceMale',
    'longRunDistanceFemale',
    'longRunDistanceNeutral',
  ];

  connect() {
    // Default values
    this.defaultValues = {
      emailVisible: false,
      phoneVisible: false,
      theme: 'system',
      inApp: true,
      requireGender: false,
      maxAllowedRequests: 3,
      longRunDistanceMale: 8,
      longRunDistanceFemale: 6,
      longRunDistanceNeutral: 7,
    };
  }

  restore() {
    // Restore default values for user settings form
    if (this.hasEmailVisibleTarget)
      this.emailVisibleTarget.checked = this.defaultValues.emailVisible;
    if (this.hasPhoneVisibleTarget)
      this.phoneVisibleTarget.checked = this.defaultValues.phoneVisible;
    if (this.hasThemeTarget) {
      this.themeTarget.value = this.defaultValues.theme;
      this.themeTarget.dispatchEvent(new Event('change'));
    }
    if (this.hasInAppTarget)
      this.inAppTarget.checked = this.defaultValues.inApp;

    // Restore default values for team settings form
    if (this.hasRequireGenderTarget) {
      this.requireGenderTarget.checked = this.defaultValues.requireGender;
      this.requireGenderTarget.dispatchEvent(new Event('change'));
    }
    if (this.hasMaxAllowedRequestsTarget)
      this.maxAllowedRequestsTarget.value =
        this.defaultValues.maxAllowedRequests;
    if (this.hasLongRunDistanceMaleTarget)
      this.longRunDistanceMaleTarget.value =
        this.defaultValues.longRunDistanceMale;
    if (this.hasLongRunDistanceFemaleTarget)
      this.longRunDistanceFemaleTarget.value =
        this.defaultValues.longRunDistanceFemale;
    if (this.hasLongRunDistanceNeutralTarget)
      this.longRunDistanceNeutralTarget.value =
        this.defaultValues.longRunDistanceNeutral;
  }
}
