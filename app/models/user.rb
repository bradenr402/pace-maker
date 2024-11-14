class User < ApplicationRecord
  # Concerns
  include UserCalculations
  include UserSettings
  include UserTeamsConcern
  include UserRunsConcern

  # Include the countries gem for dialing code lookup
  require 'countries'

  # Constants
  USERNAME_FORMAT = /\A[a-z0-9_.]{3,}\z/
  PASSWORD_FORMAT = /\A(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[#?!@$%^&*-])/

  # Devise Modules
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable,
         :omniauthable,
         omniauth_providers: [:google_oauth2],
         authentication_keys: [:login]
  # Others available are: :confirmable, :lockable, :timeoutable, and :trackable

  # Associations
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

  # Attributes
  attr_writer :login
  attr_accessor :remove_avatar

  # Enums
  enum gender: { male: 'male', female: 'female' }

  # Callbacks
  before_validation :convert_empty_string_phone_number_to_nil
  before_save :set_password_changed_at,
              if: lambda {
                # Will trigger if:
                # 1. The user is updating their password, OR
                # 2. this is a new record without any OAuth provider credentials
                # (i.e., the user created their account via email & password)
                will_save_change_to_encrypted_password? && persisted? || (new_record? && provider.blank? && uid.blank?)
              }
  before_save :format_phone_number
  before_save :purge_avatar, if: -> { remove_avatar == '1' }
  before_save :clear_avatar_url, if: -> { avatar.attached? }

  # Normalizations
  # rubocop:disable Style/SymbolProc
  normalizes :display_name, with: -> { _1.strip }
  normalizes :email, with: -> { _1.downcase.strip }
  # rubocop :enable Style/SymbolProc

  # Validations
  validates :email,
            presence: true,
            format: {
              with: URI::MailTo::EMAIL_REGEXP,
              message: 'must be a valid email address'
            },
            nondisposable_email: true
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
  validates :phone_number, phone: { possible: true, allow_blank: true }
  validates :gender,
            inclusion: {
              in: genders.keys + ['']
            },
            if: -> { gender.present? }

  # Methods
  def login = @login || username || email

  def default_name = display_name.present? ? display_name : username

  def first_name
    return username if display_name.blank?

    display_name.split(' ').first
  end

  def gender_subject
    return 'they' unless gender?

    male? ? 'he' : 'she'
  end

  def gender_object
    return 'them' unless gender?

    male? ? 'him' : 'her'
  end

  def gender_possessive
    return 'their' unless gender?

    male? ? 'his' : 'her'
  end

  def formatted_phone_number(format = :national)
    parsed_number = Phonelib.parse(phone_number, phone_country_code)

    case format
    when :national
      parsed_number.national
    when :national_with_country_code
      "+#{parsed_number.country_code} #{parsed_number.national}"
    when :international
      parsed_number.international
    when :e164
      parsed_number.e164
    else
      parsed_number.national
    end
  end

  def raw_phone_number = Phonelib.parse(phone_number, phone_country_code).raw_national

  def google_account_linked? = uid? && provider == 'google_oauth2'

  class << self
    def from_omniauth(auth)
      user = User.find_by(email: auth.info.email)
      return nil if user&.provider.nil? || user&.uid.nil?
      return user if (user&.provider == auth.provider) && (user&.uid == auth.uid)

      user =
        User.new(
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

      # If you are using :confirmable and the provider(s) you use validate emails,
      # uncomment the line below to skip the confirmation emails.
      # user.skip_confirmation!

      user.save!
      user
    end

    def generate_unique_username(base_username)
      username = base_username
      count = 1

      while User.exists?(username:)
        username = "#{base_username}_#{count}"
        count += 1
      end

      username
    end

    def generate_valid_password(length = 20)
      # Define character sets for different requirements
      # Refer to the PASSWORD_FORMAT constant for the password requirements
      upper = ('A'..'Z').to_a
      lower = ('a'..'z').to_a
      digits = ('0'..'9').to_a
      special = %w[# ? ! @ $ % ^ & * -]

      password = [upper.sample, lower.sample, digits.sample, special.sample]

      (length - password.length).times do
        password << (upper + lower + digits + special).sample
      end

      # Shuffle the password to make it more random
      password.shuffle.join
    end
  end

  private

  def ineligible_message(message) = { allowed?: false, message: }

  def password_complexity
    # Skip validation if password is blank or matches required format
    return if password.blank? || password =~ PASSWORD_FORMAT

    # Add error message if password doesn't meet complexity requirements
    errors.add(
      :password,
      'Password must include: 1 uppercase letter, 1 lowercase letter, ' \
        '1 digit, and 1 special character (#?!@$%^&*-)'
    )
  end

  def convert_empty_string_phone_number_to_nil =
    (self.phone_number = nil if phone_number.blank?)

  def format_phone_number
    parsed_phone = Phonelib.parse(phone_number, phone_country_code)
    self.phone_number = parsed_phone.international(false)
  end

  def purge_avatar
    avatar.purge_later
    self.avatar_url = nil
  end

  def clear_avatar_url = (self.avatar_url = nil)

  def set_password_changed_at = (self.password_changed_at = Time.current)

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
