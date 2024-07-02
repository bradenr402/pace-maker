class AddRequestNumberToTeamJoinRequests < ActiveRecord::Migration[7.1]
  def change
    add_column :team_join_requests, :request_number, :integer, default: 1
  end
end
