#
# Cookbook Name:: install_sc_apps
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

folder_to_install = node['install_sc_apps']['folder_to_install']
folder_git_keys   = node['install_sc_apps']['folder_git_keys']
enviroment        = node['install_sc_apps']['enviroment']

git_wrapper_path  = "#{folder_to_install}/git_wrapper.sh"

# Create dir if not exists
directory "#{folder_to_install}" do
  owner 'vagrant'
  group 'root'
  mode '0666'
  action :create
end

# Create ssh wrapper file
file git_wrapper_path do
  owner "vagrant"
  mode "0755"
  content "#!/bin/sh\nexec /usr/bin/ssh -i #{folder_git_keys}/.ssh/id_rsa \"$@\""
end


# Clone socket server
socket_app_folder = "#{folder_to_install}/socket_server"
git socket_app_folder do
  repository "git@github.com:denoww/socket-server-seucondominio.git"
  revision "master"
  action :sync
  ssh_wrapper git_wrapper_path
  user "vagrant"
end

# Clone seucondominio
sc_app_folder = "#{folder_to_install}/rails"
sc_app_repo = 'https://github.com/railstutorial/sample_app.git'
git sc_app_folder do
  repository sc_app_repo
  revision "master"
  action :sync
  ssh_wrapper git_wrapper_path
  user "vagrant"
end


gem_package 'bundler' do
  options '--no-ri --no-rdoc'
end

rvm_shell "bundle" do
  ruby_string node[:rvm][:default_ruby]
  user        "vagrant"
  group       "vagrant"
  cwd         sc_app_folder
  code        <<-EOF
    bundle install --path .bundle
  EOF
end

# config seucondominio
# tasks = ""
# case enviroment
# when "production"
# when "staging"
# when "development"
#   tasks << "rake db:setup;"
# end
  
# bash "sc_config" do
#   user "vagrant"
#   cwd  sc_app_folder
#   code <<-EOH
#     cp gitignore_sample .gitignore
#     cp config/application_sample.yml config/application.yml
#     #{tasks}
#   EOH
# end  