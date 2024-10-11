namespace :log do
  desc 'Clear development log'
  task clear: :environment do
    File.truncate(Rails.root.join('log', 'development.log'), 0)
    puts 'Development log cleared!'
  end
end
