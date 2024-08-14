class AddUniqueIndexToPhoneNumber < ActiveRecord::Migration[7.1]
  def change
    remove_index :users, :phone_number if index_exists?(:users, :phone_number)
    add_index :users,
              :phone_number,
              unique: true,
              where: 'phone_number IS NOT NULL'
  end
end
