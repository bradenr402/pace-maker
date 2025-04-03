class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      t.string :title, null: false
      t.text :description
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.string :location
      t.string :link
      t.references :team, null: false, foreign_key: true

      t.timestamps
    end
  end
end
