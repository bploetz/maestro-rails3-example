#
# Cookbook Name:: mysql-ebs
# Attributes:: default
#
# Copyright 2010, Brian Ploetz
#

set_unless[:mysql_ebs][:device] = "/dev/sdh"
set_unless[:mysql_ebs][:mount_dir] = "/vol/ebs"
