# exit on error
set -o errexit

bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean
bundle exec rails db:migrate

# If you have seeds to run, uncomment this line:
# bundle exec rails db:seed
