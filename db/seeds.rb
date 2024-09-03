# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Constants for seeding data
NUM_USERS = 15
NUM_TEAMS = 5
MIN_TEAM_MEMBERS = 5
MAX_TEAM_MEMBERS = 10

# Create users with randomized attributes
def seed_users
  users = []
  NUM_USERS.times do |i|
    users << User.find_or_create_by!(
      email: "user#{i + 1}@example.com"
    ) do |user|
      user.password = 'Password123!'
      user.username = "runner#{i + 1}"
      user.display_name = "Runner #{i + 1}"
      user.gender = ['male', 'female', ''].sample
      user.phone_number = "+1#{rand(1_000_000_000..9_999_999_999)}"
    end
  end
  users
end

# Create teams and assign members
def seed_teams_and_memberships(users)
  NUM_TEAMS.times do |i|
    ActiveRecord::Base.transaction do
      team =
        Team.create!(
          name: "Team #{i + 1}",
          description: [
            "This is team number #{i + 1}. We're excited to run together!",
            "Welcome to Team #{i + 1}! Join us for amazing running adventures.",
            "Team #{i + 1} is ready to hit the trails. Are you?",
            "Get fit and have fun with Team #{i + 1}!"
          ].sample,
          owner: users.sample,
          season_start_date: Date.today + rand(-30..30).days,
          season_end_date: Date.today + rand(2..6).months,
          mileage_goal: rand(100..500),
          long_run_goal: rand(10..30)
        )

      # Assign random number of members to each team
      users
        .sample(rand(MIN_TEAM_MEMBERS..MAX_TEAM_MEMBERS))
        .each do |user|
          next if TeamMembership.exists?(user:, team:)

          TeamMembership.create!(
            user:,
            team:,
            mileage_goal: rand(50..200),
            long_run_goal: rand(5..20)
          )
        end
    end
  end
end

# Create random runs for a user
def seed_runs_for_user(user)
  rand(5..15).times do
    Run.create!(
      user:,
      distance: rand(1.0..26.2).round(2),
      date: Date.today - rand(30),
      comments: [
        'Great run!',
        'Feeling tired',
        'Personal best!',
        'Easy jog',
        'Hill training'
      ].sample,
      duration: rand(10..120).minutes
    )
  end
end

# Create team join requests for a user
def seed_team_join_requests_for_user(user)
  rand(2..4).times do
    team = find_eligible_team(user)
    next if team.nil?

    TeamJoinRequest.create!(
      user:,
      team:,
      status: TeamJoinRequest.statuses.keys.sample,
      request_number: rand(1..3)
    )
  end
end

# Find a team that the user can join
def find_eligible_team(user)
  Team
    .where.not(owner: user)
    .where.not(id: user.teams.pluck(:id))
    .find { |team| !TeamJoinRequest.exists?(user:, team:) }
end

# Seed the database
users = seed_users
seed_teams_and_memberships(users)

users.each do |user|
  seed_runs_for_user(user)
  seed_team_join_requests_for_user(user)
end

puts 'Seed data created successfully!'
