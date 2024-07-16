class ChangeDurationNullConstraintInRuns < ActiveRecord::Migration[7.1]
  def change
    change_column_null :runs, :duration, true
  end
end
