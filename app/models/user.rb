class User < ApplicationRecord
  include UserCalculations
  include UserSettings

  USERNAME_FORMAT = /\A[a-z0-9_.]{3,}\z/
  PHONE_NUMBER_FORMAT = /\A\+?\d{10,15}\z/
  PASSWORD_FORMAT = /\A(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[#?!@$%^&*-])/

  has_many :runs, dependent: :destroy
  has_many :team_memberships, dependent: :destroy
  has_many :teams, through: :team_memberships
  has_many :owned_teams,
           class_name: 'Team',
           foreign_key: 'owner_id',
           dependent: :destroy
  has_many :join_requests,
           foreign_key: 'user_id',
           class_name: 'TeamJoinRequest',
           dependent: :destroy
  has_one_attached :avatar
  has_many :pinned_pages, dependent: :destroy

  attr_accessor :remove_avatar

  before_validation :convert_empty_string_phone_number_to_nil
  before_update :set_password_changed_at,
                if: :will_save_change_to_encrypted_password?
  before_save :purge_avatar, if: -> { remove_avatar == '1' }
  before_save :clear_avatar_url, if: -> { avatar.attached? }

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable,
         :omniauthable,
         omniauth_providers: [:google_oauth2],
         authentication_keys: [:login]

  attr_writer :login

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :username,
            presence: true,
            uniqueness: {
              case_sensitive: false
            },
            format: {
              with: USERNAME_FORMAT,
              message:
                'can only contain lowercase letters, numbers, underscores, and periods' \
                  'and must be at least 3 characters long'
            }
  validate :password_complexity
  validates :display_name, length: { maximum: 100 }, allow_blank: true
  validates :phone_number,
            uniqueness: true,
            allow_blank: true,
            format: {
              with: PHONE_NUMBER_FORMAT,
              message: 'is not a valid phone number'
            },
            if: -> { phone_number.present? }

  enum gender: { male: 'male', female: 'female' }
  validates :gender,
            inclusion: {
              in: genders.keys + ['']
            },
            if: -> { gender.present? }

  def self.from_omniauth(auth)
    return nil if User.exists?(email: auth.info.email)

    user = User.new(
      provider: auth.provider,
      uid: auth.uid,
      email: auth.info.email,
      password: generate_valid_password
    )

    # Ensure the username is unique
    base_username = auth.info.email.split('@').first
    user.username = generate_unique_username(base_username)

    user.display_name = auth.info.name
    user.avatar_url = auth.info.image

    # If you are using confirmable and the provider(s) you use validate emails,
    # uncomment the line below to skip the confirmation emails.
    # user.skip_confirmation!

    user.save!
    user
  end

  def self.generate_unique_username(base_username)
    username = base_username
    count = 1

    while User.exists?(username:)
      username = "#{base_username}_#{count}"
      count += 1
    end

    username
  end

  def self.generate_valid_password(length = 20)
    # Define character sets for different requirements
    # Refer to the PASSWORD_FORMAT constant for the password requirements
    upper = ('A'..'Z').to_a
    lower = ('a'..'z').to_a
    digits = ('0'..'9').to_a
    special = %w[# ? ! @ $ % ^ & * -]

    password = [
      upper.sample, # At least one uppercase letter
      lower.sample, # At least one lowercase letter
      digits.sample, # At least one digit
      special.sample # At least one special character
    ]

    # Fill the rest of the password length with random characters from all sets
    (length - password.length).times do
      password << (upper + lower + digits + special).sample
    end

    # Shuffle the password to make it more random
    password.shuffle.join
  end

  def login = @login || username || email

  def first_name
    return username if display_name.blank?

    display_name.split(' ').first
  end

  def gender_possessive
    return 'their' unless gender?

    male? ? 'his' : 'her'
  end

  def gender_object
    return 'them' unless gender?

    male? ? 'him' : 'her'
  end

  def gender_subject
    return 'they' unless gender?

    male? ? 'he' : 'she'
  end

  def runs_in_date_range(range) = runs.in_date_range(range)

  def runs_today = runs.today

  def run_on_day?(date) = runs.where(date: date.all_day).exists?

  def long_run_on_day?(date, team) =
    runs.where(date: date.all_day).any? { |run| run.long_run_for?(team) }

  def member_of?(team) = teams.include?(team)

  def membered_teams = teams.where.not(owner_id: id)

  def default_name = display_name.present? ? display_name : username

  def other_teams =
    Team.not_included_in(teams.pluck(:id) + owned_teams.pluck(:id))

  def owns?(team) = self == team.owner

  def eligibility_for_team_membership(team)
    return ineligible_message('Team not found.') if team.nil?

    return ineligible_message('You are the owner of this team.') if owns?(team)

    return ineligible_message('You are already a member of this team.') if member_of?(team)

    existing_request = TeamJoinRequest.find_by(user: self, team:)
    return ineligible_message('You have already requested to join this team.') if existing_request&.pending?

    if existing_request&.rejected? && existing_request.request_number >= team.max_allowed_requests
      return ineligible_message('You have been blocked from joining this team.')
    end

    unless team.gender_requirement_met?(self)
      return ineligible_message('You must specify your gender to join this team.')
    end

    { allowed?: true, message: 'You meet the requirements to join this team.' }
  end

  def teams_requiring_gender =
    teams.includes(:setting_objects).select(&:require_gender?)

  def any_teams_require_gender? = teams_requiring_gender.any?

  def teams_in_common(other_user) =
    teams.select { |team| other_user.teams.include?(team) }

  def any_teams_in_common?(other_user) = teams_in_common(other_user).any?

  def owned_teams_in_common(other_user) =
    owned_teams.select { |team| other_user.teams.include?(team) }

  def any_owned_teams_in_common?(other_user) =
    owned_teams_in_common(other_user).any?

  def membered_teams_in_common(other_user) =
    membered_teams.select { |team| other_user.teams.include?(team) }

  def any_membered_teams_in_common?(other_user) =
    membered_teams_in_common(other_user).any?

  def membered_teams_in_common_except(other_user, exclude: []) =
    membered_teams
      .select { |team| other_user.membered_teams.include?(team) }
      .reject { |team| exclude.include?(team) }

  def any_membered_teams_in_common_except?(other_user, exclude: []) =
    membered_teams_in_common_except(other_user, exclude:).any?

  def google_account_linked? = uid? && provider == 'google_oauth2'

  private

  def ineligible_message(message) = { allowed?: false, message: }

  def password_complexity
    return if password.blank? || password =~ PASSWORD_FORMAT

    errors.add :password,
               'Complexity requirement not met. Password must include at least ' \
                 '1 uppercase letter, 1 lowercase letter, 1 digit, and 1 special character (#?!@$%^&*-)'
  end

  def convert_empty_string_phone_number_to_nil =
    (self.phone_number = nil if phone_number.blank?)

  def purge_avatar
    avatar.purge_later
    self.avatar_url = nil
  end

  def clear_avatar_url = (self.avatar_url = nil)

  def set_password_changed_at = self.password_changed_at = Time.current

  class << self
    def find_for_database_authentication(warden_conditions)
      conditions = warden_conditions.dup
      if (login = conditions.delete(:login))
        where(conditions.to_h).where(
          [
            'lower(username) = :value OR lower(email) = :value',
            { value: login.strip.downcase }
          ]
        ).first
      elsif conditions.key?(:username) || conditions.key?(:email)
        where(conditions.to_h).first
      end
    end
  end
end
