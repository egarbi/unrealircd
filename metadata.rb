maintainer        "Gaurav Gupta"
maintainer_email  "gaurav@nimbuzz.com"
license           "Apache 2.0"
description       "Installs and configures Sanity"
version           "0.0.1"
recipe            "unrealircd", "Installs and configures an IRCD with API and modules"

%w{ubuntu debian}.each do |os|
  supports os
end

recipe "unrealircd::server", "Install unrealircd and put config files in place"
