class CreatePinnedPages < ActiveRecord::Migration[7.1]
  def change
    create_table :pinned_pages do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.string :page_url

      t.timestamps
    end
  end
end
