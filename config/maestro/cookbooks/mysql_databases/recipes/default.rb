begin
  t = resources(:template => "/etc/mysql/create_databases.sql")
rescue
  Chef::Log.warn("Could not find previously defined create_databases.sql resource")
  t = template "/etc/mysql/create_databases.sql" do
    source "create_databases.sql.erb"
    owner "root"
    group "root"
    mode "0700"
    action :create
  end
end

execute "mysql-create-databases" do
  command "/usr/bin/mysql -u root -p#{node[:mysql][:server_root_password]} < /etc/mysql/create_databases.sql"
  action :run
end
