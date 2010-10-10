maintainer        "bploetz"
license           "Apache 2.0"
description       "Configures a MySQL server to use an EBS volume for it's storage, based on Eric Hammond's post."
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version           "0.1.0"
recipe            "mysql_ebs::esh", "Configures a MySQL server to use an EBS volume for it's storage, based on Eric Hammond's post."

%w{ debian ubuntu }.each do |os|
  supports os
end


attribute "mysql_ebs/device",
  :display_name => "EBS Device",
  :description => "The device the EBS volume is attached as.",
  :default => "/dev/sdh"

attribute "mysql_ebs/mount_dir",
  :display_name => "MySQL EBS Volume mount directory",
  :description => "Directory the EBS volume should be mounted as",
  :default => "/vol/ebs"
