class User < ApplicationRecord
  include UserCalculations
  include UserSettings

  USERNAME_FORMAT = /\A[a-z0-9_.]{3,}\z/
  PHONE_NUMBER_FORMAT = /\A\+?\d{10,15}\z/

  before_validation :convert_empty_string_phone_number_to_nil

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

  before_save :purge_avatar, if: -> { remove_avatar == '1' }

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable,
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
    return 'he' unless gender?

    male? ? 'him' : 'her'
  end

  def runs_in_date_range(range) = runs.in_date_range(range)

  def runs_today = runs.today

  def run_on_day?(date) = runs.where(date: date.all_day).exists?

  def long_run_on_day?(date, team) = runs.where(date: date.all_day).any? { |run| run.long_run_for?(team) }

  def member_of?(team) = teams.include?(team)

  def membered_teams = teams.where.not(owner_id: id)

  def default_name = display_name.present? ? display_name : username

  def other_teams =
    Team.not_included_in(teams.pluck(:id) + owned_teams.pluck(:id))

  def owns?(team) = self == team.owner

  def meets_requirements?(team)
    return { allowed?: false, message: 'Team not found.' } if team.nil?

    if team.require_gender? && gender.blank?
      return(
        {
          allowed?: false,
          message: 'You must specify your gender to join this team.'
        }
      )
    end

    { allowed?: true, message: 'You meet the requirements to join this team.' }
  end

  def teams_requiring_gender = teams.select(&:require_gender?)

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

  private

  def password_complexity
    return if password.blank?

    password_regex = /(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[#?!@$%^&*-])/

    unless password =~ password_regex
      errors.add :password,
                 'Complexity requirement not met. Password must include at least ' \
                   '1 uppercase letter, 1 lowercase letter, 1 digit, and 1 special character (#?!@$%^&*-)'
    end
  end

  def convert_empty_string_phone_number_to_nil =
    (self.phone_number = nil if phone_number.blank?)

  def purge_avatar = avatar.purge_later

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
