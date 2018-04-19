require 'bundler/setup'
require 'pry'
require 'simplecov'
require 'factory_bot'

SimpleCov.start do
  add_filter 'spec/'
end

require "warren"

Warren.logger.level = Logger::INFO
Dir[Warren.root.join('spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Setup FactoryBot
  config.include FactoryBot::Syntax::Methods
  config.before(:suite) do
    FactoryBot.find_definitions
  end

  config.include NotionSpecHelpers::IsAnticipated

  config.order = :random
  config.color = true

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
