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

# Create dir if not exists
directory "#{folder_apps}" do
  # owner 'vagrant'
  # group 'root'
  # mode '0666'
  action :create
end

# Create ssh wrapper file
file ssh_file_wrapper do
  owner "vagrant"
  mode "0755"
  content "#!/bin/sh\nexec /usr/bin/ssh -i #{folder_ssh_config}/id_rsa \"$@\""
end


file "#{home_guest}/.bashrc" do
  cwd Chef::Config[:file_cache_path]
  code <<-EOF

    # ~/.bashrc: executed by bash(1) for non-login shells.
    # see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
    # for examples

    alias sc:k='killall -9 node; killall -9 ruby'
    alias sc:cd='cd ~/apps/seucondominio'
    alias sc:s='sc:cd; sc:k; foreman start -f Procfile.dev'
    alias sc:c='spring rails c'
    alias sc:g='guard'
    alias sc:r='spring rake'

    alias sc:test='RAILS_ENV=test'
    alias sc:test:c='sc:test sc:c'
    alias sc:test:r='sc:test sc:r'

    alias sc:staging='RAILS_ENV=staging'
    alias sc:staging:c='sc:staging sc:c'
    alias sc:staging:r='sc:staging sc:r'

    alias sc:production='RAILS_ENV=production'
    alias sc:production:c='sc:production sc:c'
    alias sc:production:r='sc:production sc:r'

  EOF
  not_if { ::File.exists?(install_path) }
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
# sc_app_folder = "#{folder_apps}/rails"
# sc_app_repo = 'https://github.com/railstutorial/sample_app.git'
git sc_app_folder do
  repository sc_app_repo
  # revision "master"
  revision "vagrant"
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
  tasks << "rake db:drop;"
  tasks << "rake db:mongoid:drop;"
  tasks << "rake db:setup;"
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