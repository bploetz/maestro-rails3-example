#
# Cookbook Name:: nginx
# Recipe:: source
#
# Author:: Adam Jacob (<adam@opscode.com>)
# Author:: Joshua Timberman (<joshua@opscode.com>)
#
# Copyright 2009, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

gem_package "passenger" do
  action :install
  version "#{node[:passenger][:version]}"
end

bash "add_nginx_user_and_group" do
  code <<-EOH
    adduser --system --no-create-home --disabled-login --disabled-password --group nginx
  EOH
end

include_recipe "build-essential"

%w{ libpcre3 libpcre3-dev libssl-dev}.each do |devpkg|
  package devpkg
end

nginx_version = node[:nginx][:version]
nginx_dir = node[:nginx][:dir]
configure_flags = node[:nginx][:configure_flags].join(" ")

remote_file "/tmp/nginx-#{nginx_version}.tar.gz" do
  source "http://nginx.org/download/nginx-#{nginx_version}.tar.gz"
  action :create_if_missing
end

directory node[:nginx][:dir] do
  owner "root"
  group "root"
  mode "0755"
  action :create
  recursive true
  not_if "test -d #{node[:nginx][:dir]}"
end

directory node[:nginx][:conf_dir] do
  owner "root"
  group "root"
  mode "0755"
  action :create
  recursive true
  not_if "test -d #{node[:nginx][:conf_dir]}"
end

directory node[:nginx][:ssl_dir] do
  owner "root"
  group "root"
  mode "0755"
  action :create
  recursive true
  not_if "test -d #{node[:nginx][:ssl_dir]}"
end

directory node[:nginx][:log_dir] do
  mode "0755"
  owner node[:nginx][:user]
  group node[:nginx][:group]
  action :create
  recursive true
  not_if "test -d #{node[:nginx][:log_dir]}"
end

%w{ sites-enabled conf.d }.each do |dir|
  directory "#{node[:nginx][:dir]}/#{dir}" do
    owner "root"
    group "root"
    mode "0755"
    not_if "test -d #{node[:nginx][:dir]}/#{dir}"
  end
end

bash "compile_nginx_source" do
  cwd "/tmp"
  code <<-EOH
    sudo tar zxf nginx-#{nginx_version}.tar.gz
    cd nginx-#{nginx_version} && sudo ./configure #{configure_flags}
    sudo make && sudo make install
  EOH
end

template "nginx-initd" do
  path "/etc/init.d/nginx"
  source "nginx-initd.erb"
  owner "root"
  group "root"
  mode "0644"
end

# Make it executable and add it to the default run levels
bash "add_nginx_to_run_levels" do
  code <<-EOH
    sudo chmod +x /etc/init.d/nginx
    sudo /usr/sbin/update-rc.d -f nginx defaults
  EOH
end

# add the init.d service
service "nginx" do
  service_name "nginx"
  status_command "sudo /etc/init.d/nginx status"
  stop_command "sudo /etc/init.d/nginx stop"
  start_command "sudo /etc/init.d/nginx start"
  restart_command "sudo /etc/init.d/nginx restart"
  reload_command "sudo /etc/init.d/nginx reload"
  supports :status => true, :restart => true, :reload => true
  action :nothing
end

remote_file "#{node[:nginx][:conf_dir]}/mime.types" do
  source "mime.types"
  owner "root"
  group "root"
  mode "0644"
end

remote_file "#{node[:nginx][:ssl_dir]}/server.crt" do
  source "server.crt"
  owner "root"
  group "root"
  mode "0600"
end

remote_file "#{node[:nginx][:ssl_dir]}/server.key" do
  source "server.key"
  owner "root"
  group "root"
  mode "0600"
end

template "common.include" do
  path "#{node[:nginx][:dir]}/sites-enabled/common.include"
  source "common.include.erb"
  owner "root"
  group "root"
  mode "0644"
end

template "maestro-rails3-example.conf" do
  path "#{node[:nginx][:dir]}/sites-enabled/maestro-rails3-example.conf"
  source "maestro-rails3-example.conf.erb"
  owner "root"
  group "root"
  mode "0644"
end

template "nginx.conf" do
  path "#{node[:nginx][:conf_dir]}/nginx.conf"
  source "nginx.conf.erb"
  owner "root"
  group "root"
  mode "0644"
end

service "nginx" do
  action :reload
end

# let monit start nginx......
