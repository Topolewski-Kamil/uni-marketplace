## Application deployment configuration
set :server,      'epi-stu-hut-demo3.shef.ac.uk'
set :user,        'demo.team17'
set :deploy_to,   -> { "/srv/services/#{fetch(:user)}" }
set :log_level,   :debug
set :rvm_ruby_version, 'ruby-2.6.6'

## Server configuration
server fetch(:server), user: fetch(:user), roles: %w{web app db}

## Additional tasks
namespace :deploy do
  task :seed do
    on primary :db do within current_path do with rails_env: fetch(:stage) do
      execute :rake, 'db:seed'
    end end end
  end
end