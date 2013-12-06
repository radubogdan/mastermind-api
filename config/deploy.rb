require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/rbenv'

# Set rails environment
set :rails_env, 'production'

set :domain,     '37.139.18.214'
set :deploy_to,  "/home/dot/mastermind/#{rails_env}"
set :app_path,   "#{deploy_to}/#{current_path}"
set :repository, 'git@github.com:radubogdan/mastermind-api.git'
set :branch,     'master'


# Manually create these paths in shared/ (eg: shared/config/database.yml) in your server.
# They will be linked in the 'deploy:link_shared_paths' step.
set :shared_paths, ['config/database.yml', 'log', 'tmp', 'public/uploads']
set :term_mode, :system

# Optional settings:
set :user, 'dot'  # Username in the server to SSH to.
set :ssh_options, '-A'

task :environment do
  invoke :'rbenv:load'
end
# Put any custom mkdir's in here for when `mina setup` is ran.
# For Rails apps, we'll make some of the shared paths that are shared between
# all releases.
task setup: :environment do
  queue! %[mkdir -p "#{deploy_to}/shared/tmp"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/tmp"]

  queue! %[mkdir -p "#{deploy_to}/shared/tmp/pids"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/tmp/pids"]

  queue! %[mkdir -p "#{deploy_to}/shared/tmp/sockets"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/tmp/sockets"]

  queue! %[mkdir -p "#{deploy_to}/shared/log"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/log"]

  queue! %[mkdir -p "#{deploy_to}/shared/config"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/config"]

  queue! %[touch "#{deploy_to}/shared/config/database.yml"]
end

desc "Deploys the current version to the server."
task deploy: :environment do
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'

    to :launch do
      invoke :'unicorn:restart'
    end
  end
end

namespace :unicorn do
  set :unicorn_pid, "#{app_path}/tmp/pids/unicorn.pid"

  desc "Start unicorn"
  task start: :environment do
    queue 'echo "-----> Start Unicorn"'
    queue! %{
      cd #{app_path}
      bundle exec unicorn -c #{app_path}/config/unicorn.rb -E #{rails_env} -D
    }
  end

  desc "Stop unicorn"
  task :stop do
    queue 'echo "-----> Stop Unicorn"'
    queue! %{
      test -s "#{unicorn_pid}" && kill -QUIT `cat "#{unicorn_pid}"` && echo "Stop Ok" && exit 0
      echo >&2 "Not running"
    }
  end

  desc "Graceful reload unicorn"
  task :reload do
    queue 'echo "-----> Reload Unicorn"'
    queue! %{
      test -s "#{unicorn_pid}" && kill -s USR2 `cat "#{unicorn_pid}"` && echo "Reload Ok" && exit 0
      echo >&2 "Not running"
    }
  end

  desc "Restart unicorn using 'upgrade'"
  task restart: :environment do
    invoke 'unicorn:stop'
    invoke 'unicorn:start'
  end
end
