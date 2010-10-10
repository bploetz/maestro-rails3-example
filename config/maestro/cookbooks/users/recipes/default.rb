group "deploy"  do
  action :create
  ignore_failure true
end

bash "create_deploy_user" do
  code <<-EOH
    useradd -s '/bin/bash' -m -d '/home/deploy' -g deploy deploy
  EOH
  ignore_failure true
end

bash "add_deploy_user_to_admin_group" do
  code <<-EOH
    sudo usermod -a -G admin deploy
  EOH
  ignore_failure true
end

bash "add_deploy_user_to_sudoers" do
  code <<-EOH
    sudo su - root
    sudo sh -c 'echo "deploy ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers'
    exit
  EOH
end

directory "/home/deploy/.ssh"  do
  owner "deploy"
  group "deploy"
  mode "0700"
  action :create
  not_if "test -d /home/deploy/.ssh"
end

cookbook_file "/home/deploy/.ssh/id_rsa-deploy.pub"  do
  source "id_rsa-deploy.pub"
  mode "0700"
end

bash "add_deploy_public_key_to_authorized_keys" do
  code <<-EOH
    sudo touch /home/deploy/.ssh/authorized_keys2
    chown deploy:deploy /home/deploy/.ssh/authorized_keys2
    sudo cat /home/deploy/.ssh/id_rsa-deploy.pub >> /home/deploy/.ssh/authorized_keys2
  EOH
end

directory "/mnt/apps"  do
  owner "deploy"
  group "deploy"
  mode "0755"
  action :create
  not_if "test -d /mnt/apps"
end
