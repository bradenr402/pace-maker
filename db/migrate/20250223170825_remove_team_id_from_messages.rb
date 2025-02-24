class RemoveTeamIdFromMessages < ActiveRecord::Migration[8.0]
  def change
    remove_reference :messages, :team, null: false, foreign_key: true
  end
end
