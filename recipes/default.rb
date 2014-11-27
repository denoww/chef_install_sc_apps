#
# Cookbook Name:: install_sc_apps
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

folder_apps       = node['sc_config']['folder_apps']
enviroment        = node['sc_config']['enviroment']
folder_ssh_config = node['sc_config']['folder_ssh_config']
home_guest        = node['sc_config']['home_guest']
ssh_file_wrapper  = "#{folder_ssh_config}/git_wrapper.sh"

##########################################
# BASH, ALIAS and PROFILE
##########################################
bashrc             = "#{home_guest}/.bashrc"
bash_aliases       = "#{home_guest}/.bash_aliases"
profile            = "#{home_guest}/.profile"


file bashrc do
  owner "root"
  mode "0755"
  action :create
  content IO.read("/etc/skel/.bashrc")
  not_if { ::File.exists?(bashrc) }
end

file profile do
  owner "root"
  mode "0755"
  action :create
  content <<-EOF
    # ~/.profile: executed by the command interpreter for login shells.
    # This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
    # exists.
    # see /usr/share/doc/bash/examples/startup-files for examples.
    # the files are located in the bash-doc package.

    # the default umask is set in /etc/profile; for setting the umask
    # for ssh logins, install and configure the libpam-umask package.
    #umask 022

    # if running bash
    if [ -n "$BASH_VERSION" ]; then
        # include .bashrc if it exists
        if [ -f "$HOME/.bashrc" ]; then
      . "$HOME/.bashrc"
        fi
    fi

    # set PATH so it includes user's private bin if it exists
    if [ -d "$HOME/bin" ] ; then
        PATH="$HOME/bin:$PATH"
    fi


  EOF
  not_if { ::File.exists?(profile) }
end



file bash_aliases do
  owner "root"
  #mode "0755"
  content <<-EOF

    alias sc:k='killall -9 node; killall -9 ruby'
    alias sc_k='sc:k'

    alias sc:cd='cd #{folder_apps}/seucondominio'
    alias sc_cd='sc:cd'

    alias sc:s='sc:cd; sc:k; foreman start -f Procfile.dev'
    alias sc_s='sc:s'

    alias sc:c='sc:cd; spring rails c'
    alias sc_c='sc:c'

    alias sc:g='sc:cd; guard'
    alias sc_g='sc:g'

    alias sc:r='sc:cd; spring rake'
    alias sc_r='sc:r'

    alias sc:test='RAILS_ENV=test'
    alias sc_test='sc:test'

    alias sc:test:c='sc:test sc:c'
    alias sc_test_c='sc:test:c'

    alias sc:test:r='sc:test sc:r'
    alias sc_test_r='sc:test:r'

    alias sc:staging='RAILS_ENV=staging'
    alias sc_staging='sc:staging'

    alias sc:staging:c='sc:staging sc:c'
    alias sc_staging_c='sc:staging:c'

    alias sc:staging:r='sc:staging sc:r'
    alias sc_staging_r='sc:staging:r'

    alias sc:production='RAILS_ENV=production'
    alias sc_production='sc:production'

    alias sc:production:c='sc:production sc:c'
    alias sc_production_c='sc:production:c'

    alias sc:production:r='sc:production sc:r'
    alias sc_production_r='sc:production:r'

  EOF
  not_if { ::File.exists?(bash_aliases) }
end




##########################################
# APPS SC
##########################################

# Create ssh wrapper file
file ssh_file_wrapper do
  owner "vagrant"
  mode "0755"
  content "#!/bin/sh\nexec /usr/bin/ssh -i #{folder_ssh_config}/id_rsa \"$@\""
end

# Create dir if not exists
directory "#{folder_apps}" do
  action :create
end

# Clone socket server
socket_app_folder = "#{folder_apps}/socket_server"
git socket_app_folder do
  repository "git@github.com:denoww/socket-server-seucondominio.git"
  revision "master"
  action :sync
  ssh_wrapper ssh_file_wrapper
  user "vagrant"
end

# Clone seucondominio
sc_app_folder = "#{folder_apps}/seucondominio"
sc_app_repo = 'git@github.com:denoww/seucondominio.git'
git sc_app_folder do
  repository sc_app_repo
  revision "master"
  action :sync
  ssh_wrapper ssh_file_wrapper
  user "vagrant"
end


gem_package 'bundler' do
  options '--no-ri --no-rdoc'
end

rvm_shell "bundle" do
  ruby_string node[:rvm][:default_ruby]
  user        "root"
  group       "root"
  cwd         sc_app_folder
  code        <<-EOF
    bundle install
  EOF
end

# config seucondominio
tasks = ""
case enviroment
when "production"
when "staging"
when "development"
  tasks << "echo 'Creating and feeding database';"
  # development
  tasks << "RAILS_ENV=development rake db:drop;"
  tasks << "RAILS_ENV=development rake db:mongoid:drop;"
  tasks << "RAILS_ENV=development rake db:setup;"
  # test
  tasks << "RAILS_ENV=test rake db:drop;"
  tasks << "RAILS_ENV=test rake db:mongoid:drop;"
  tasks << "RAILS_ENV=test rake db:setup;"
end

bash "sc_config" do
  user "vagrant"
  cwd  sc_app_folder
  code <<-EOH
    cp gitignore_sample .gitignore
    cp config/application_sample.yml config/application.yml
    #{tasks}
  EOH
end
