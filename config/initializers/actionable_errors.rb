module ActiveRecord
  class PendingMigrationError < MigrationError
    include ActiveSupport::ActionableError

    action 'Run pending migrations' do
      ActiveRecord::Tasks::DatabaseTasks.migrate
    end
  end
end
