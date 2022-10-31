# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'simplecov'
SimpleCov.start 'rails'

ENV["RAILS_ENV"] ||= 'test'
require 'spec_helper'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# If the test database needs migrating, load in the current schema
if ActiveRecord::Base.connection.migration_context.needs_migration?
  puts('Loading schema into test database...')
  ActiveRecord::Tasks::DatabaseTasks.load_schema_current
end
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.include Shoulda::Matchers::ActiveRecord
  config.include Shoulda::Matchers::ActiveModel

  config.include Capybara::DSL              # Let's us use the capybara stuf in our specs
  config.include Warden::Test::Helpers      # Let's us do login_as(user)
  config.include Rails.application.routes.url_helpers
  config.include Capybara::Select2
  config.include Devise::TestHelpers, type: :controller

  config.after(:each) do
    Warden.test_reset!
  end

  config.mock_with :rspec

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation, { pre_count: true, reset_ids: false, except: %w(ar_internal_metadata) })
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation, { pre_count: true, reset_ids: false, except: %w(ar_internal_metadata) }
  end

  config.after(:each, js: true) do
    expect(current_path).to eq current_path
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.before(:each) do
    ActionMailer::Base.deliveries.clear
  end


  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!
end

Webdrivers.install_dir = Rails.root.join('vendor', 'webdrivers')
Webdrivers.cache_time = 86_400

require 'selenium/webdriver'
Capybara.register_driver :chrome do |app|
  chrome_options = Selenium::WebDriver::Chrome::Options.new
  chrome_options.add_argument('--headless') unless ENV['SHOW_CHROME']
  chrome_options.add_argument('--no-sandbox')
  chrome_options.add_argument('--disable-gpu')
  chrome_options.add_argument('--disable-dev-shm-usage')
  chrome_options.add_argument('--disable-infobars')
  chrome_options.add_argument('--disable-extensions')
  chrome_options.add_argument('--disable-popup-blocking')
  chrome_options.add_argument('--window-size=1920,4320')

  # LTSP has multiple versions of Chrome installed, so prefer Chromium
  LTSP_BIN = '/usr/bin/chromium-browser'
   if File.exist?(LTSP_BIN)
     chrome_options.binary = LTSP_BIN
   end

   # Rails takes a little time to start, so wait ~2 mins before failing
   client = Selenium::WebDriver::Remote::Http::Default.new
   client.read_timeout = 120 # seconds

   Capybara::Selenium::Driver.new app, browser: :chrome, options: chrome_options, http_client: client
end

Capybara.configure do |config|
  config.asset_host = 'http://localhost:3000'
  require 'capybara/apparition'
  config.javascript_driver = :apparition
  config.server = :webrick
  config.match = :prefer_exact
end

def wait_for_ajax
  Timeout.timeout(Capybara.default_max_wait_time) do
    loop do
      break if page.evaluate_script('jQuery.active') == 0
      sleep 0.5
    end
  end
end
