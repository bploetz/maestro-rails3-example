maintainer        "bploetz"
license           "Apache 2.0"
description       "Sets up MySQL databases"
version           "0.1"

%w{ ubuntu debian redhat centos }.each do |os|
  supports os
end
