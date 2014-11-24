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

ssh_file_wrapper  = "#{folder_ssh_config}/git_wrapper.sh"

# Create dir if not exists
directory "#{folder_apps}" do
  owner 'vagrant'
  group 'root'
  mode '0666'
  action :create
end

# Create ssh wrapper file
file ssh_file_wrapper do
  owner "vagrant"
  mode "0755"
  content "#!/bin/sh\nexec /usr/bin/ssh -i #{folder_ssh_config}/id_rsa \"$@\""
end


# Clone socket server
socket_app_folder = "#{folder_apps}/socket_server"
git socket_app_folder do
  repository "git@github.com:denoww/socket-server-seucondominio.git"
  revision "master"
  action :sync
  ssh_wrapper ssh_file_wrapper
  user "root"
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
  user "root"
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
  tasks << "bundle exec rake db:drop;"
  tasks << "bundle exec rake db:mongoid:drop;"
  tasks << "bundle exec rake db:setup;"
end
  
bash "sc_config" do
  user "root"
  cwd  sc_app_folder
  code <<-EOH
    cp gitignore_sample .gitignore
    cp config/application_sample.yml config/application.yml
    #{tasks}
  EOH
end  