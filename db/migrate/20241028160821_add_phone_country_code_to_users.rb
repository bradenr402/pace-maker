class AddPhoneCountryCodeToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :phone_country_code, :string
  end
end
