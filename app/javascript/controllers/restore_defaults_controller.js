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
    'weekStart',
    'includeSaturday',
    'includeSunday',
    'streakDistanceMale',
    'streakDistanceFemale',
    'streakDistanceNeutral',
    'streaksIncrement',
    'mileageIncrement',
    'longRunsIncrement',
  ];

  connect() {
    // Default settings
    // Refer to [user_settings.rb](/app/models/user_settings.rb) and [team_settings.rb](/app/models/team_settings.rb) for more info

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
      weekStart: 'monday',
      includeSaturday: false,
      includeSunday: false,
      streakDistanceMale: 2,
      streakDistanceFemale: 2,
      streakDistanceNeutral: 2,
      streaksIncrement: 10,
      mileageIncrement: 50,
      longRunsIncrement: 5,
    };
  }

  restore() {
    this.restoreUserSettings();
    this.restoreTeamSettings();
  }

  restoreUserSettings() {
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
  }

  restoreTeamSettings() {
    // Restore default values for team settings form
    if (this.hasRequireGenderTarget) {
      this.requireGenderTarget.checked = this.defaultValues.requireGender;

      // Show/hide long run distance fields with [team_gender_fields_controller](./team_gender_fields_controller.js)
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

    if (this.hasWeekStartTarget)
      this.weekStartTarget.value = this.defaultValues.weekStart;

    if (this.hasIncludeSaturdayTarget)
      this.includeSaturdayTarget.checked = this.defaultValues.includeSaturday;

    if (this.hasIncludeSundayTarget)
      this.includeSundayTarget.checked = this.defaultValues.includeSunday;

    if (this.hasStreakDistanceMaleTarget)
      this.streakDistanceMaleTarget.value = this.defaultValues.streakDistanceMale;

    if (this.hasStreakDistanceFemaleTarget)
      this.streakDistanceFemaleTarget.value = this.defaultValues.streakDistanceFemale;

    if (this.hasStreakDistanceNeutralTarget)
      this.streakDistanceNeutralTarget.value = this.defaultValues.streakDistanceNeutral;

    if (this.hasStreaksIncrementTarget)
      this.streaksIncrementTarget.value = this.defaultValues.streaksIncrement;

    if (this.hasMileageIncrementTarget)
      this.mileageIncrementTarget.value = this.defaultValues.mileageIncrement;

    if (this.hasLongRunsIncrementTarget)
      this.longRunsIncrementTarget.value = this.defaultValues.longRunsIncrement;
  }
}
