class AddPositionToPinnedPages < ActiveRecord::Migration[7.1]
  def change
    add_column :pinned_pages, :position, :integer
  end
end
