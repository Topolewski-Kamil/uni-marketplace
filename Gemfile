source "https://rubygems.org"
ruby '2.6.6'
git_source(:github) { |repo_name| "https://github.com/#{repo_name}.git" }
git_source(:gitlab) { |repo_name| "git@git.shefcompsci.org.uk:#{repo_name}.git" }

gem 'airbrake', github: 'epigenesys/airbrake', branch: 'airbrake-v4'
gem 'rubycas-client', gitlab: 'gems/rubycas-client'
gem 'epi_cas', gitlab: 'gems/epi_cas'
gem 'epi_js'

gem 'rails', '6.0.3.3'
gem 'activerecord-session_store'
gem 'bootsnap'
gem 'responders'
gem 'puma'

gem 'pg'

gem 'haml-rails'
gem 'sassc-rails'
gem 'sassc'
gem 'uglifier'
gem 'coffee-rails'

gem 'jquery-rails'
gem 'bootstrap'
gem 'font-awesome-sass'

gem 'simple_form'
gem 'draper'
gem 'ransack'

gem 'will_paginate'
gem 'bootstrap-will_paginate'

gem 'devise'
gem 'devise_ldap_authenticatable'
gem 'devise_cas_authenticatable'
gem 'cancancan'

gem 'whenever'
gem 'delayed_job'
gem 'delayed_job_active_record'
gem 'delayed-plugins-airbrake'
gem 'daemons', '1.1.9'

group :development, :test do
  gem 'rspec-rails'
  gem 'byebug'
  gem 'sqlite3'
end

group :development do
  gem 'epi_deploy', github: 'epigenesys/epi_deploy'

  gem 'listen'
  gem 'web-console'

  gem 'capistrano'
  gem 'capistrano-rails', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-rvm', require: false
  gem 'capistrano-passenger', require: false

  gem 'eventmachine'
  gem 'letter_opener'
  gem 'annotate'
end

group :test do
  gem 'capybara-select2', github: 'goodwill/capybara-select2'
  gem 'factory_bot_rails'
  gem 'shoulda-matchers'
  gem 'capybara'
  gem 'webdrivers'
  gem 'rspec-instafail', require: false

  gem 'database_cleaner'
  gem 'launchy'
  gem 'simplecov'

  gem 'apparition'
end

gem "redcarpet", "~> 3.5"
