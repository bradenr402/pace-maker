class CreateTeamJoinRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :team_join_requests do |t|
      t.references :user, null: false, foreign_key: true
      t.references :team, null: false, foreign_key: true
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
