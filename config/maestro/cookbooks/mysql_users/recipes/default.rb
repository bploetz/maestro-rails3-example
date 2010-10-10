begin
  t = resources(:template => "/etc/mysql/create_users.sql")
rescue
  Chef::Log.warn("Could not find previously defined create_users.sql resource")
  t = template "/etc/mysql/create_users.sql" do
    source "create_users.sql.erb"
    owner "root"
    group "root"
    mode "0700"
    action :create
  end
end

begin
  t = resources(:template => "/etc/mysql/grant_user_privileges.sql")
rescue
  Chef::Log.warn("Could not find previously defined grant_user_privileges.sql resource")
  t = template "/etc/mysql/grant_user_privileges.sql" do
    source "grant_user_privileges.sql.erb"
    owner "root"
    group "root"
    mode "0700"
    action :create
  end
end

execute "mysql-create-users" do
  command "/usr/bin/mysql -u root -p#{node[:mysql][:server_root_password]} < /etc/mysql/create_users.sql"
  action :nothing
  subscribes :run, resources(:template => "/etc/mysql/create_users.sql")
  ignore_failure true
end

execute "mysql-grant-user-privileges" do
  command "/usr/bin/mysql -u root -p#{node[:mysql][:server_root_password]} < /etc/mysql/grant_user_privileges.sql"
  action :nothing
  subscribes :run, resources(:template => "/etc/mysql/grant_user_privileges.sql")
  ignore_failure true
end
