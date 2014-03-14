#
# Cookbook Name:: unrealircd
# Recipe:: server
#
# Copyright 2013, example.com
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'unrealircd::server_apache'

f=file "/var/lib/apt/periodic/update-success-stamp" do
  action :nothing
end

%w[ make libssl-dev eggdrop libnet-smpp-perl ].each do |pkg|
  package "#{pkg}" do
    action:install
  end
end

# Ircd
version = node['unrealircd']['ircd']['version']
install_path = "/opt"

# Creating config directory
directory "#{node['unrealircd']['conf_dir']}" do
  owner "irc"
  group "root"
  mode 0755
end

#Creating log directory
directory "#{node['unrealircd']['log_dir']}" do
  owner "irc"
  group "root"
  mode 0775
end

directory "#{node['unrealircd']['log_dir']}/channels" do
  owner "irc"
  group "root"
  mode 0775
end

# Placing future configuration files on the right path
%w[ req cert key ].each do |type|
  cookbook_file "#{node['unrealircd']['conf_dir']}/server.#{type}.pem" do
    source "server.#{type}.pem"
    owner "irc"
    group "root"
    if type.eql?('req')
      mode 0600
    elsif type.eql?('cert')
      mode 0644
    else 
      mode 0400
    end
  end
end

%w[ badwords.channel badwords.message badwords.quit help spamfilter unrealircd ].each do |file|
  template "#{node['unrealircd']['conf_dir']}/#{file}.conf" do
    source "#{file}.conf.erb"
    owner "irc"
    group "root"
    mode 0600
  end
end


# Downloading tar.gz from unrealircd.com
remote_file "#{Chef::Config[:file_cache_path]}/Unreal#{version}.tar.gz" do
  source "#{node['unrealircd']['ircd']['url']}"
  checksum node['unrealircd']['ircd']['checksum']
  mode "0644"
  not_if "test -f #{Chef::Config[:file_cache_path]}/Unreal#{version}.tar.gz" 
end

# Placing configure option before launch Config script.
template "#{Chef::Config[:file_cache_path]}/config.settings" do
  source "config.settings.erb"
  mode 0644
end

# Placing configure option before launch Config script(Anope).
template "#{Chef::Config[:file_cache_path]}/config.cache" do
  source "config.cache.erb"
  mode 0644
  variables :ircdpath => "#{install_path}/Unreal#{version}"
end


# Extracting, building and compiling unrealirc daemon from source
bash "build-and-install-ircd" do
  cwd Chef::Config[:file_cache_path]
  code <<-EOF
    tar xvzf Unreal#{version}.tar.gz -C #{install_path}/
    cp ./config.settings #{install_path}/Unreal#{version}/
    (cd #{install_path}/Unreal#{version} && ./Config)
    (cd #{install_path}/Unreal#{version} && make)
  EOF
  not_if "test -d #{install_path}/Unreal#{version}"
end

link "#{node['unrealircd']['prefix_dir']}" do
  to "#{install_path}/Unreal#{version}"
end

version = node['unrealircd']['anope']['version']

# Anope, Sercices NickServ, ChanServ, etc
# Downloading tar.gz from http://sourceforge.net/projects/anope/files/
remote_file "#{Chef::Config[:file_cache_path]}/anope-#{version}.tar.gz" do
  source "#{node['unrealircd']['anope']['url']}"
  mode "0644"
  not_if "test -f #{Chef::Config[:file_cache_path]}/anope-#{version}.tar.gz" 
end


bash "build-and-install-anope" do
  cwd Chef::Config[:file_cache_path]
  code <<-EOF
    tar xvzf anope-#{version}.tar.gz -C #{install_path}/
    cp ./config.cache #{install_path}/anope-#{version}/
    (cd #{install_path}/anope-#{version} && ./Config -nointro -quick && make && make install)
    chown -R irc:root #{node['unrealircd']['prefix_dir']}/
  EOF
  not_if "test -d #{install_path}/anope-#{version}"
end

# Placing configure file for anope.
template "#{node['unrealircd']['prefix_dir']}/services/services.conf" do
  source "services.conf.erb"
  mode 0644
end


# Eggdrop
directory "#{node['unrealircd']['eggdrop']['conf_dir']}" do
  owner "irc"
  group "root"
  mode 0755
end
directory "#{node['unrealircd']['eggdrop']['conf_dir']}/scripts" do
  owner "irc"
  group "root"
  mode 0755
end

template "#{node['unrealircd']['eggdrop']['conf_dir']}/eggdrop.conf" do
  source "eggdrop.conf.erb"
  owner "irc"
  group "root"
  mode 0644
end

%w[ sms dlearn ].each do |script|
  cookbook_file "#{node['unrealircd']['eggdrop']['conf_dir']}/scripts/#{script}.tcl" do
    source "#{script}.tcl"
    owner "irc"
    group "root"
    mode 0644
  end
end
