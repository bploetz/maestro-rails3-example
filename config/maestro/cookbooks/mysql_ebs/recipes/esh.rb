#
# Cookbook Name:: mysql-ebs
# Recipe:: esh
#
# Copyright 2010, Brian Ploetz
#
# An implementation of Eric Hammond's (@esh) instructions here:
# http://developer.amazonwebservices.com/connect/entry.jspa?categoryID=100&externalID=1663
#
# This recipe assumes your EBS volume is already attached to the node at mysql_ebs[:device].
#

include_recipe "xfs"
include_recipe "mysql::server"

# Install XFS module to kernel if necessary
bash "install_xfs" do
  code <<-EOC
    sudo modprobe xfs
  EOC
  not_if "grep -q xfs /proc/filesystems"
end

# Create an XFS file system on the device if necessary
# Note: xfs_check returns 3 when the file system doesn't exist, 1 when it does.
# This doesn't work well with Chef's default not_if/only_if. JIRA raised:
# http://tickets.opscode.com/browse/CHEF-1261
bash "create_xfs_filesystem" do
  code <<-EOC
    sudo mkfs.xfs #{node[:mysql_ebs][:device]}
  EOC
  ignore_failure true
end

# Create the mount dir if necessary
directory "#{node[:mysql_ebs][:mount_dir]}" do
  owner "root"
  group "root"
  mode "0755"
  recursive true
  action :create
  not_if "test -d #{node[:mysql_ebs][:mount_dir]}"
end

# Mount the device to the specified directory
mount "#{node[:mysql_ebs][:mount_dir]}"  do
  device "#{node[:mysql_ebs][:device]}"
  device_type :device
  fstype "xfs"
  options "defaults"
  action [:mount, :enable]
end

service "mysql" do
  action :stop
end

# Create the mysql dirs on the EBS volume if necessary
directory "#{node[:mysql_ebs][:mount_dir]}/etc" do
  owner "root"
  group "root"
  mode "0755"
  recursive true
  action :create
  not_if "test -d #{node[:mysql_ebs][:mount_dir]}/etc"
end

directory "#{node[:mysql_ebs][:mount_dir]}/lib" do
  owner "root"
  group "root"
  mode "0755"
  recursive true
  action :create
  not_if "test -d #{node[:mysql_ebs][:mount_dir]}/lib"
end

directory "#{node[:mysql_ebs][:mount_dir]}/log" do
  owner "root"
  group "root"
  mode "0755"
  recursive true
  action :create
  not_if "test -d #{node[:mysql_ebs][:mount_dir]}/log"
end

# Since the /etc/mysql/my.cnf template has already been slapped down with
# the correct IP address for this node, move it aside, and then put it back
# when we're done, such that we don't use the my.cnf file from the EBS volume
# with the WRONG IP address. MySQL won't start in this case (obviously).
bash "move_etc_mysql_my_cnf_aside" do
  code <<-EOC
    sudo mv /etc/mysql/my.cnf /tmp/my.cnf
  EOC
end

bash "move_etc_mysql_dir" do
  code <<-EOC
    sudo mv /etc/mysql #{node[:mysql_ebs][:mount_dir]}/etc/
  EOC
  not_if "test -d #{node[:mysql_ebs][:mount_dir]}/etc/mysql"
end

bash "move_var_lib_mysql_dir" do
  code <<-EOC
    sudo mv /var/lib/mysql #{node[:mysql_ebs][:mount_dir]}/lib/
  EOC
  not_if "test -d #{node[:mysql_ebs][:mount_dir]}/lib/mysql"
end

bash "move_var_log_mysql_dir" do
  code <<-EOC
    sudo mv /var/log/mysql #{node[:mysql_ebs][:mount_dir]}/log/
  EOC
  not_if "test -d #{node[:mysql_ebs][:mount_dir]}/log/mysql"
end

directory "/etc/mysql" do
  owner "root"
  group "root"
  mode "0755"
  recursive true
  action :create
  not_if "test -d /etc/mysql"
end

directory "/var/lib/mysql" do
  owner "mysql"
  group "mysql"
  mode "0700"
  recursive true
  action :create
  not_if "test -d /var/lib/mysql"
end

directory "/var/log/mysql" do
  owner "mysql"
  group "adm"
  mode "2740"
  recursive true
  action :create
  not_if "test -d /var/log/mysql"
end

bash "bind_etc_mysql_to_ebs" do
  code <<-EOC
    echo "#{node[:mysql_ebs][:mount_dir]}/etc/mysql /etc/mysql     none bind" | sudo tee -a /etc/fstab
    sudo mount /etc/mysql
  EOC
  not_if "grep -q \"#{node[:mysql_ebs][:mount_dir]}/etc/mysql /etc/mysql     none bind\" /etc/fstab"
end

bash "bind_var_lib_mysql_to_ebs" do
  code <<-EOC
    echo "#{node[:mysql_ebs][:mount_dir]}/lib/mysql /var/lib/mysql none bind" | sudo tee -a /etc/fstab
    sudo mount /var/lib/mysql
  EOC
  not_if "grep -q \"#{node[:mysql_ebs][:mount_dir]}/lib/mysql /var/lib/mysql none bind\" /etc/fstab"
end

bash "bind_var_log_mysql_to_ebs" do
  code <<-EOC
    echo "#{node[:mysql_ebs][:mount_dir]}/log/mysql /var/log/mysql none bind" | sudo tee -a /etc/fstab
    sudo mount /var/log/mysql
  EOC
  not_if "grep -q \"#{node[:mysql_ebs][:mount_dir]}/log/mysql /var/log/mysql none bind\" /etc/fstab"
end

# Now, move the original /etc/mysql/my.cnf back
bash "restore_etc_mysql_my_cnf" do
  code <<-EOC
    sudo mv /tmp/my.cnf /etc/mysql/my.cnf
  EOC
end

# The Chef service doesn't seem to deal with a status command that returns 0 for everything
# (thinks the service is already running and thus won't start it).
#service "mysql" do
#  action :start
#end

# Do it manually to force the issue.
bash "start_mysql" do
  code <<-EOC
    sudo start mysql
  EOC
  only_if "sudo status mysql | grep -q \"mysql stop/waiting\""
end

# install the consistent snapshot utility
bash "install_consistent_snapshot" do
  code <<-EOC
    codename=$(lsb_release -cs)
    echo "deb http://ppa.launchpad.net/alestic/ppa/ubuntu $codename main" | sudo tee /etc/apt/sources.list.d/alestic-ppa.list    
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys BE09C571
    sudo apt-get update
    sudo apt-get install -y ec2-consistent-snapshot
    sudo PERL_MM_USE_DEFAULT=1 cpan Net::Amazon::EC2
  EOC
end

bash "enable_multiverse" do
  code <<-EOC
    sudo sh -c 'echo deb http://gb.archive.ubuntu.com/ubuntu/ lucid multiverse >> /etc/apt/sources.list'
    sudo sh -c 'echo deb-src http://gb.archive.ubuntu.com/ubuntu/ lucid multiverse >> /etc/apt/sources.list'
    sudo sh -c 'echo deb http://gb.archive.ubuntu.com/ubuntu/ lucid-updates multiverse >> /etc/apt/sources.list'
    sudo sh -c 'echo deb-src http://gb.archive.ubuntu.com/ubuntu/ lucid-updates multiverse >> /etc/apt/sources.list'
    sudo apt-get update
  EOC
end

package "openjdk-6-jre" do
  action :install
end

package "ec2-api-tools" do
  action :install
end

remote_file "/mnt/aws-cert.pem" do
  source "aws-cert.pem"
  owner "root"
  group "root"
  mode "0600"
end

remote_file "/mnt/aws-pk.pem" do
  source "aws-pk.pem"
  owner "root"
  group "root"
  mode "0600"
end

cron "db_snapshot" do
  action :create
  minute "17"
  command <<-EOC
    sudo ec2-consistent-snapshot --aws-access-key-id #{node[:mysql_ebs][:aws_access_key_id]} --aws-secret-access-key #{node[:mysql_ebs][:aws_secret_access_key]} --description \"MySQL DB snapshot\" --xfs-filesystem #{node[:mysql_ebs][:mount_dir]} --mysql --mysql-host localhost --mysql-username root --mysql-password #{node[:mysql][:server_root_password]} #{node[:mysql_ebs][:ebs_volume_id]} > /dev/null 2>&1
  EOC
end

template "ebs_snapshot_cleanup_script" do
  path "/mnt/ebs_snapshot_cleanup.sh"
  source "ebs_snapshot_cleanup.erb"
  owner "root"
  group "root"
  mode "0744"
end


cron "ebs_snapshot_cleanup" do
  action :create
  minute "49"
  command <<-EOC
    /mnt/ebs_snapshot_cleanup.sh > /dev/null 2>&1
  EOC
end
