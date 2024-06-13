class ChangeDistanceColumnToDecimal < ActiveRecord::Migration[7.1]
  def up
    change_column :runs, :distance, :decimal, precision: 6, scale: 3, null: false
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
