module TeamSettings
  extend ActiveSupport::Concern
  include ActionView::Helpers::TextHelper

  def self.defaults
    {
      join_requirements: {
        require_gender: false,
        max_allowed_requests: 3
      },
      long_runs: {
        long_run_distance_male: 8,
        long_run_distance_female: 6,
        long_run_distance_neutral: 7
      },
      streaks: {
        include_saturday: false,
        include_sunday: false,
        streak_distance_male: 2,
        streak_distance_female: 2,
        streak_distance_neutral: 2
      },
      milestones: {
        streaks_increment: 10,
        mileage_increment: 50,
        long_runs_increment: 5
      },
      general: {
        week_start: :monday
      }
    }
  end

  def self.keys = defaults.keys

  def reset_settings_to_defaults
    settings(:join_requirements).update(TeamSettings.defaults[:join_requirements])
    settings(:long_runs).update(TeamSettings.defaults[:long_runs])
    settings(:streaks).update(TeamSettings.defaults[:streaks])
    settings(:milestones).update(TeamSettings.defaults[:milestones])
    settings(:general).update(TeamSettings.defaults[:general])
  end

  included do
    has_settings do |s|
      s.key :join_requirements, defaults: TeamSettings.defaults[:join_requirements]
      s.key :long_runs, defaults: TeamSettings.defaults[:long_runs]
      s.key :streaks, defaults: TeamSettings.defaults[:streaks]
      s.key :milestones, defaults: TeamSettings.defaults[:milestones]
      s.key :general, defaults: TeamSettings.defaults[:general]
    end

    def track_settings_changes
      # rubocop :disable Style/HashEachMethods
      TeamSettings.keys.each do |key|
        settings(key).saved_changes.each do |attribute, changes|
          next if attribute == 'updated_at'

          old_value, new_value = changes

          old_value = process_yaml_value(old_value)
          new_value = process_yaml_value(new_value)

          if attribute == 'value' && old_value.is_a?(Hash) && new_value.is_a?(Hash)
            (old_value.keys | new_value.keys).each do |setting_key|
              next if [:max_allowed_requests, 'max_allowed_requests'].include?(setting_key)

              old_setting_value = process_bool_value(old_value[setting_key])
              new_setting_value = process_bool_value(new_value[setting_key])

              next if old_setting_value == new_setting_value

              attribute_name = if [:require_gender, 'require_gender'].include?(setting_key)
                                 'gender_required'
                               else
                                 setting_key
                               end

              team_audits.create!(
                attribute_name: "#{attribute_name}_setting",
                old_value: old_setting_value.to_s,
                new_value: new_setting_value.to_s,
                changed_at: Time.current
              )
            end
          else
            next if attribute == 'max_allowed_requests'

            old_value = process_bool_value(old_value)
            new_value = process_bool_value(new_value)

            next if old_value == new_value

            attribute_name = attribute_name.to_s
            attribute_name = if attribute_name == 'require_gender'
                               'gender_required'
                             elsif %w[streak_distance_neutral long_run_distance_neutral].include?(attribute_name)
                              attribute_name.gsub('_neutral', '')
                             else
                               attribute_name
                             end

            team_audits.create!(
              attribute_name: "#{attribute_name}_setting",
              old_value: old_value,
              new_value: new_value,
              changed_at: Time.current
            )
          end
        end
      end
    end
    # rubocop :enable Style/HashEachMethods

    private def process_bool_value(value)
      if value.to_s == 'f'
        false
      elsif value.to_s == 't'
        true
      else
        value
      end
    end

    private def process_yaml_value(value)
      if value.is_a?(String) && value.start_with?('---')
        YAML.load(value)
      else
        value
      end
    end
  end

  def setting_explanation(key, value)
    case key.to_s
    when 'require_gender', 'gender_required'
      if value
        'This setting requires users to specify their gender to request to join this team.'
      else
        'This setting allows users to request to join this team without specifying their gender.'
      end
    when 'week_start'
      'This setting determines the start of the week for the calendars on the team page and your member page.'
    when 'long_run_distance_male', 'long_run_distance_female', 'long_run_distance_neutral'
      "This setting means you must run at least #{pluralize(value, 'mile')} for a run to count as a long run."
    when 'streak_distance_male', 'streak_distance_female', 'streak_distance_neutral'
      "This setting means that you must run at least #{pluralize(value, 'mile')} for a run to count towards your streak."
    when 'include_saturday'
      'This setting allows your streak to continue even if you skip running on a Saturday. You can still advance your streak by logging a run.'
    when 'include_sunday'
      'This setting allows your streak to continue even if you skip running on a Sunday. You can still advance your streak by logging a run.'
    when 'streaks_increment'
      "This setting awards you a new streak milestone badge on your team member profile for every #{pluralize_simple(value, 'day')} of your current streak."
    when 'long_runs_increment'
      "This setting awards you a new long run milestone badge on your team member profile for every #{pluralize_simple(value, 'long run')} you complete."
    when 'mileage_increment'
      "This setting awards you a new mileage milestone badge on your team member profile for every #{pluralize_simple(value, 'mile')} you run."
    else
      "#{key}, #{value}"
    end
  end
  alias setting_explanation_for setting_explanation

  def pluralize_simple(count, word)
    return word if count.to_f == 1.0 # rubocop:disable Lint/FloatComparison

    pluralize(count, word)
  end

  def require_gender? = settings(:join_requirements).require_gender
  def max_allowed_requests = settings(:join_requirements).max_allowed_requests.to_i

  def week_start = settings(:general).week_start.to_sym

  def long_run_distance_male = settings(:long_runs).long_run_distance_male.to_i
  def long_run_distance_female = settings(:long_runs).long_run_distance_female.to_i
  def long_run_distance_neutral = settings(:long_runs).long_run_distance_neutral.to_i

  def include_saturday_in_streak? = settings(:streaks).include_saturday
  def include_sunday_in_streak? = settings(:streaks).include_sunday
  def exclude_saturday_from_streak? = !include_saturday_in_streak?
  def exclude_sunday_from_streak? = !include_sunday_in_streak?

  def include_date_in_streak?(date) =
    (date.saturday? && include_saturday_in_streak?) ||
      (date.sunday? && include_sunday_in_streak?)

  def exclude_date_from_streak?(date) =
    (date.saturday? && exclude_saturday_from_streak?) ||
      (date.sunday? && exclude_sunday_from_streak?)

  def streak_distance_male = settings(:streaks).streak_distance_male.to_i
  def streak_distance_female = settings(:streaks).streak_distance_female.to_i
  def streak_distance_neutral = settings(:streaks).streak_distance_neutral.to_i

  def streaks_increment = settings(:milestones).streaks_increment.to_i
  def long_runs_increment = settings(:milestones).long_runs_increment.to_i
  def mileage_increment = settings(:milestones).mileage_increment.to_i
end
