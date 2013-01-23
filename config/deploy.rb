#Capistrano support
require 'torquebox-capistrano-support'
require 'bundler/capistrano'

# source code
set :application,       "geograph-agent-farm"
set :repository,        "https://github.com/algorithmica/geograph-agent-farm.git"
set :branch,            "master"
set :user,              "torquebox"
set :scm,               :git
set :scm_verbose,       true
set :use_sudo,          false
#set :test_server,       "vm-178.uc.futuregrid.org"
# Production server

set :deploy_to,         "/opt/apps/#{application}"
set :torquebox_home,    "/opt/torquebox/current"
set :jboss_init_script, "/etc/init.d/jboss-as-standalone"
#set :app_environment,   "RAILS_ENV: production" DOES NOT WORK!!!
set :app_context,       "/farm"
set :app_ruby_version,  '1.9'


#Added by vittorio
#default_run_options[:pty] = true
#ssh_options[:verbose] = :debug
ssh_options[:auth_methods] = "publickey"
ssh_options[:keys] = %w(~/.ssh/id_rsa)
set :deploy_via, :remote_cache

ssh_options[:forward_agent] = false

#Precompile asset pipeline
load 'deploy/assets'


role :web, "10.100.0.100"
role :app, "10.100.0.100"
role :db,  "10.100.0.100", :primary => true
