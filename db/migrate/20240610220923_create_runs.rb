class CreateRuns < ActiveRecord::Migration[7.1]
  def change
    create_table :runs do |t|
      t.float :distance
      t.time :time
      t.date :date
      t.text :comments
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
