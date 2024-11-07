class CreateTeamAudits < ActiveRecord::Migration[7.1]
  def change
    create_table :team_audits do |t|
      t.references :team, null: false, foreign_key: true
      t.string :attribute_name
      t.text :old_value
      t.text :new_value
      t.datetime :changed_at

      t.timestamps
    end
  end
end
