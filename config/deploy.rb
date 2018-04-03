# config valid for current version and patch releases of Capistrano
lock "~> 3.10.1"

# set :application, "my_app_name"
# set :repo_url, "git@example.com:me/my_repo.git"

set :application, 'photoshop'
set :repo_url, 'git@github.com:Omkasokuluk/photoshop.git'
set :deploy_to, '/home/deploy/photoshop'
set :scm, :git
set :rvm_ruby_version, '2.5.1'

append :linked_dirs, 'log', 'tmp'
append :linked_files, '.env', 'config/puma.rb', 'config/database.yml', 'config/secrets.yml'

set :foreman_init_system, 'systemd'
set :foreman_export_path, '/lib/systemd/system'
set :foreman_options, app: fetch(:application), root: current_path, log: File.join(shared_path, 'log')

namespace :deploy do
  task :restart do
    on roles(:app) do |host|
      f = "#{fetch :foreman_export_path}/#{fetch(:foreman_options)[:app]}.conf"
      if test("[ -f #{f} ]")
        invoke 'foreman:restart'
      else
        invoke 'foreman:setup'
      end
    end
  end

  desc "Fix file permissions"
  task :fix_file_permissions do
    on roles(:app) do
      execute "chown -R #{fetch :application} #{shared_path}/tmp"
      execute "chown -R #{fetch :application} #{shared_path}/log"
    end
  end

  task :check_env do
    on roles(:all) do |host|
      f = "#{shared_path}/.env"
      if test("[ -f #{f} ]")
        info "#{f} already exists on #{host}!"
      else
        execute "echo 'RAILS_ENV=#{fetch :stage}' > #{f}"
        execute "echo 'PATH=/usr/local/rvm/wrappers/#{fetch(:rvm_ruby_version)}:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' >> #{f}"
      end
    end
  end

  before 'check:linked_files', :check_env
  after :publishing, :fix_file_permissions
  after :publishing, :restart
end

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml", "config/secrets.yml"

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure
