%w[ 000-default ].each do |site|
  apache_site site do
    enable false
  end
end

%w[ status ].each do |mod|
  apache_module mod do
    conf true
  end
end

case node['irc']['server_auth_method']
when "ldap"
    include_recipe "apache2::mod_authnz_ldap" # Enable ldap auth module
else
  template "#{node['unrealircd']['conf_dir']}/htpasswd.users" do
    source "htpasswd.users.erb"
    owner "irc"
    group web_group
    mode 0644
  end
end

# Set variable public_domain with example.com or whatever, Not used yet
if node[:public_domain]
  case node.chef_environment
  when "Nimbuzz"
    public_domain = node[:public_domain]
  else
    public_domain = "#{node.chef_environment}.#{node[:public_domain]}"
  end
else
  public_domain = node[:domain]
end

template "#{node[:apache][:dir]}/sites-available/irc.conf" do
  source "apache2.conf.erb"
  mode 0644
  variables(:docroot => node['irc']['docroot'], :ldap_url => node['irc']['ldap_url'])
end

cookbook_file "#{node['apache']['dir']}/ssl/example.crt" do
  source "example.crt"
  mode 0644
  notifies :restart, resources(:service => "apache2")
end

cookbook_file "#{node['apache']['dir']}/ssl/example.key" do
  source "example.key"
  mode 0400
  notifies :restart, resources(:service => "apache2")
end

# Creates symbolic link on sites-enabled
apache_site "irc.conf"
