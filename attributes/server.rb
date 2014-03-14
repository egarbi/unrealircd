
set['unrealircd']['log_dir'] = "/var/log/unrealircd"
set['unrealircd']['ircd']['version'] = "3.2.10.1"
set['unrealircd']['ircd']['checksum'] = "97b4bd68a804e517355efa756f401a90"
set['unrealircd']['ircd']['url'] = "http://www.unrealircd.com/downloads/Unreal#{node['unrealircd']['ircd']['version']}.tar.gz"
set['unrealircd']['prefix_dir'] = "/opt/unreal"
set['unrealircd']['conf_dir'] = "/etc/unreal"
set['unrealircd']['modules_dir'] = "/opt/unreal/src/modules"

#Anope
set['unrealircd']['anope']['version'] = "1.8.8"
set['unrealircd']['anope']['url'] = "http://sourceforge.net/projects/anope/files/anope-stable/Anope%20#{node['unrealircd']['anope']['version']}/anope-#{node['unrealircd']['anope']['version']}.tar.gz"

#Eggdrop
set['unrealircd']['eggdrop']['conf_dir'] = "/etc/eggdrop"
