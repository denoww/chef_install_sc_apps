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
  # owner "root"
  #mode "0755"
  action :create_if_missing
  #content IO.read("/etc/skel/.bashrc")
  content "# ~/.bashrc: executed by bash(1) for non-login shells.\n# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)\n# for examples\n\n# If not running interactively, don't do anything\ncase $- in\n    *i*) ;;\n      *) return;;\nesac\n\n# don't put duplicate lines or lines starting with space in the history.\n# See bash(1) for more options\nHISTCONTROL=ignoreboth\n\n# append to the history file, don't overwrite it\nshopt -s histappend\n\n# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)\nHISTSIZE=1000\nHISTFILESIZE=2000\n\n# check the window size after each command and, if necessary,\n# update the values of LINES and COLUMNS.\nshopt -s checkwinsize\n\n# If set, the pattern \"**\" used in a pathname expansion context will\n# match all files and zero or more directories and subdirectories.\n#shopt -s globstar\n\n# make less more friendly for non-text input files, see lesspipe(1)\n[ -x /usr/bin/lesspipe ] && eval \"$(SHELL=/bin/sh lesspipe)\"\n\n# set variable identifying the chroot you work in (used in the prompt below)\nif [ -z \"${debian_chroot:-}\" ] && [ -r /etc/debian_chroot ]; then\n    debian_chroot=$(cat /etc/debian_chroot)\nfi\n\n# set a fancy prompt (non-color, unless we know we \"want\" color)\ncase \"$TERM\" in\n    xterm-color) color_prompt=yes;;\nesac\n\n# uncomment for a colored prompt, if the terminal has the capability; turned\n# off by default to not distract the user: the focus in a terminal window\n# should be on the output of commands, not on the prompt\n#force_color_prompt=yes\n\nif [ -n \"$force_color_prompt\" ]; then\n    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then\n\t# We have color support; assume it's compliant with Ecma-48\n\t# (ISO/IEC-6429). (Lack of such support is extremely rare, and such\n\t# a case would tend to support setf rather than setaf.)\n\tcolor_prompt=yes\n    else\n\tcolor_prompt=\n    fi\nfi\n\nif [ \"$color_prompt\" = yes ]; then\n    PS1='${debian_chroot:+($debian_chroot)}\\[\\033[01;32m\\]\\u@\\h\\[\\033[00m\\]:\\[\\033[01;34m\\]\\w\\[\\033[00m\\]\\$ '\nelse\n    PS1='${debian_chroot:+($debian_chroot)}\\u@\\h:\\w\\$ '\nfi\nunset color_prompt force_color_prompt\n\n# If this is an xterm set the title to user@host:dir\ncase \"$TERM\" in\nxterm*|rxvt*)\n    PS1=\"\\[\\e]0;${debian_chroot:+($debian_chroot)}\\u@\\h: \\w\\a\\]$PS1\"\n    ;;\n*)\n    ;;\nesac\n\n# enable color support of ls and also add handy aliases\nif [ -x /usr/bin/dircolors ]; then\n    test -r ~/.dircolors && eval \"$(dircolors -b ~/.dircolors)\" || eval \"$(dircolors -b)\"\n    alias ls='ls --color=auto'\n    #alias dir='dir --color=auto'\n    #alias vdir='vdir --color=auto'\n\n    alias grep='grep --color=auto'\n    alias fgrep='fgrep --color=auto'\n    alias egrep='egrep --color=auto'\nfi\n\n# some more ls aliases\nalias ll='ls -alF'\nalias la='ls -A'\nalias l='ls -CF'\n\n# Add an \"alert\" alias for long running commands.  Use like so:\n#   sleep 10; alert\nalias alert='notify-send --urgency=low -i \"$([ $? = 0 ] && echo terminal || echo error)\" \"$(history|tail -n1|sed -e '\\''s/^\\s*[0-9]\\+\\s*//;s/[;&|]\\s*alert$//'\\'')\"'\n\n# Alias definitions.\n# You may want to put all your additions into a separate file like\n# ~/.bash_aliases, instead of adding them here directly.\n# See /usr/share/doc/bash-doc/examples in the bash-doc package.\n\nif [ -f ~/.bash_aliases ]; then\n    . ~/.bash_aliases\nfi\n\n# enable programmable completion features (you don't need to enable\n# this, if it's already enabled in /etc/bash.bashrc and /etc/profile\n# sources /etc/bash.bashrc).\nif ! shopt -oq posix; then\n  if [ -f /usr/share/bash-completion/bash_completion ]; then\n    . /usr/share/bash-completion/bash_completion\n  elif [ -f /etc/bash_completion ]; then\n    . /etc/bash_completion\n  fi\nfi\n"
  #not_if { ::File.exists?(bashrc) }
end

file profile do
  # owner "vagrant"
  #mode "0755"
  #action :create
  action :create_if_missing
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
  # not_if { ::File.exists?(profile) }
end



file bash_aliases do
  # owner "vagrant"
  #mode "0755"
  action :create_if_missing
  content <<-EOF

    alias sc:k='killall -9 node; killall -9 ruby'
    alias sc_k='sc:k'

    alias sc:cd='cd #{folder_apps}/seucondominio'
    alias sc_cd='sc:cd'

    alias sc:s='sc:cd; sc:k; foreman start -f Procfile.dev'
    alias sc_s='sc:s'

    alias sc:c='sc:cd; spring rails c'
    alias sc_c='sc:c'

    alias sc:g='sc:cd; spring rails g'
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
  # not_if { ::File.exists?(bash_aliases) }
end




##########################################
# APPS SC
##########################################

# Create ssh wrapper file
file ssh_file_wrapper do
  #owner "root"
  mode "0777"
  action :create
  #content "#!/bin/sh\nexec /usr/bin/ssh -i #{folder_ssh_config}/id_rsa \"$@\""
  content "/usr/bin/env ssh -o StrictHostKeyChecking=no -i #{folder_ssh_config}/id_rsa $1 $2"
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
  tasks << "bundle exec rake sc:seed;"
end

bash "sc_config" do
  # user "vagrant"
  cwd  sc_app_folder
  code <<-EOH
    cp gitignore_sample .gitignore
    cp config/application_sample.yml config/application.yml
    #{tasks}
  EOH
end
