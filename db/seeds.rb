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

puts 'Cleaning up existing data...'
User.where.not(id: 1).destroy_all
TeamMembership.where.not(user_id: 1).destroy_all
Team.where.not(owner_id: 1).destroy_all

# Create users with randomized attributes
def seed_users
  puts "Creating #{NUM_USERS} users..."
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
  puts 'Users created successfully!'
  users
end

# Create teams and assign members
def seed_teams_and_memberships(users)
  puts "Creating #{NUM_TEAMS} teams and assigning members..."
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
      puts "Created team: #{team.name}"

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
      puts "Assigned members to team: #{team.name}"
    end
  end
  puts 'Teams and memberships created successfully!'
end

# Create random runs for a user
def seed_runs_for_user(user)
  if [true, false].sample && rand < 0.2 # Only for ~10% of users
    puts "Creating runs for user: #{user.username} (sample)"
    num_consecutive_runs = rand(10..50)
    num_consecutive_runs.times do |i|
      Run.create!(
        user:,
        distance: rand(1.0..26.2).round(2),
        date: Date.today - i,
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
  else
    puts "Creating runs for user: #{user.username}"
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
end

# Create team join requests for a user
def seed_team_join_requests_for_user(user)
  puts "Creating team join requests for user: #{user.username}"
  rand(2..4).times do
    team = find_eligible_team(user)
    next if team.nil?

    request = TeamJoinRequest.create!(
      user:,
      team:,
      status: TeamJoinRequest.statuses.keys.sample,
      request_number: rand(1..3)
    )

    # Create membership if request was approved
    next unless request.approved?

    TeamMembership.create(
      user: user,
      team: team
    )
  end
end

# Find a team that the user can join
def find_eligible_team(user)
  Team
    .where.not(owner: user)
    .where.not(id: user.membered_teams.pluck(:id))
    .find { |team| !TeamJoinRequest.exists?(user:, team:) }
end

# Seed the database
puts 'Starting database seeding process...'
users = seed_users
seed_teams_and_memberships(users)

puts 'Creating runs and team join requests for all users...'
users.each do |user|
  seed_runs_for_user(user)
  seed_team_join_requests_for_user(user)
end

puts 'Creating data for admin user (ID: 1)...'
me = User.find(1)

# Create some runs for my account
puts 'Creating runs for admin user...'
5.times do
  Run.create!(
    user: me,
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

puts 'Creating team join requests for admin user...'
TeamJoinRequest.statuses.each_key do |status|
  rand(2..4).times do
    team = find_eligible_team(me)
    next if team.nil?

    request = TeamJoinRequest.create!(
      user: me,
      team: team,
      status: status,
      request_number: rand(1..3)
    )

    # Create membership if request was approved
    next unless request.approved?

    TeamMembership.create(
      user: me,
      team: team
    )
  end
end

# Create join requests and memberships for my test team
puts 'Creating join requests and memberships for test team (id: 1)...'
my_team = Team.find(1)
User.where.not(id: my_team.members.pluck(:id)).each do |user|
  # Create join request
  request = TeamJoinRequest.create(
    user: user,
    team: my_team,
    status: TeamJoinRequest.statuses.keys.sample,
    request_number: rand(1..3)
  )

  # Create membership if request was approved
  next unless request.approved?

  TeamMembership.create(
    user: user,
    team: my_team
  )
end

# Update some teams with new information
puts 'Updating random teams with new information...'
Team.order('RANDOM()').limit(3).each do |current_team|
  current_team.update(
    name: [
      'Speedy Sprinters',
      'Distance Demons',
      'Trail Blazers',
      'Marathon Masters',
      'Track Stars',
      'Road Runners',
      'Endurance Elite',
      'Pace Setters',
      'Swift Squad',
      'Mountain Movers',
      'Urban Striders',
      'Peak Performers'
    ].sample.concat(" #{rand(1..999)}"),
    season_start_date: Date.new(2024, [1, 3, 6].sample, rand(1..28)),
    season_end_date: Date.new(2024, [9, 11, 12].sample, rand(1..28)),
    description: [
      'A competitive team focused on improving speed and endurance',
      'Casual runners who enjoy group training sessions',
      'Dedicated athletes preparing for upcoming races',
      'Mixed ability team welcoming runners of all levels',
      'Specialized training group for distance events'
    ].sample
  )
  puts "Updated team: #{current_team.name}"
end

puts 'Seed data created successfully!'
