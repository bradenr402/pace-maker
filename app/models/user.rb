class User < ApplicationRecord
  has_many :runs, dependent: :destroy
  has_many :team_memberships, dependent: :destroy
  has_many :teams, through: :team_memberships
  has_many :owned_teams,
           class_name: 'Team',
           foreign_key: 'owner_id',
           dependent: :destroy
  has_many :team_join_requests

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
              with: /\A[a-z0-9_.]{3,}\z/,
              message:
                'can only contain lowercase letters, numbers, underscores, and periods' \
                  'and must be at least 3 characters long'
            }
  validate :password_complexity

  def login
    @login || username || email
  end

  def total_miles
    runs.sum(:distance)
  end

  def total_duration
    runs.sum(:duration)
  end

  def total_km
    (total_miles * 1.609344).round(3)
  end

  def runs_between(start_date, end_date)
    runs.where(date: start_date..end_date).order(date: :desc)
  end

  def runs_in_range(range)
    runs.where(date: range).order(date: :desc)
  end

  def member_of?(team)
    teams.include?(team)
  end

  def membered_teams
    teams.where.not(owner_id: id)
  end

  def other_teams
    owned_team_ids = owned_teams.pluck(:id)
    team_ids = teams.pluck(:id)
    Team.where.not(id: owned_team_ids + team_ids)
  end

  def owns?(team) = self == team.owner

  def miles_this_season(team)
    Run
      .joins(user: :teams)
      .where(user: { id: })
      .where(teams: { id: team.id })
      .where(date: team.season_start_date..team.season_end_date)
      .sum(:distance)
  end

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
