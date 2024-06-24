class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def edited?
    created_at != updated_at
  end
end
