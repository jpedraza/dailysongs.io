ENV["RAILS_ENV"] ||= "test"

require File.expand_path("../../config/environment", __FILE__)
require "rspec/rails"

Dir[Rails.root.join("spec/support/**/*.rb")].each do |file|
  require file
end

# Checks for pending migrations before tests are run.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  config.infer_spec_type_from_file_location!
end
