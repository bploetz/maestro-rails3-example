package "monit" do
  action :install
end

bash "start_monit" do
  code <<-EOC
    sudo stop monit
  EOC
  ignore_failure true
end

template "/etc/monit/monitrc" do
  owner "root"
  group "root"
  mode 0700
  source 'monitrc.erb'
end

template "/etc/default/monit" do
  owner "root"
  group "root"
  mode 0644
  source 'monit.erb'
end

directory "/var/monit" do
  owner "root"
  group "root"
  mode  0644
end

execute "restart-monit" do
  command "sudo pkill -9 monit && sudo monit"
  action :nothing
end

bash "start_monit" do
  code <<-EOC
    sudo monit
  EOC
end
