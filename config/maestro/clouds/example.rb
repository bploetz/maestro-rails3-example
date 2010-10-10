aws_cloud :example do

  keypair_name "XXXXXXX-keypair"
  keypair_file "/path/to/id_rsa-XXXXXXX-keypair"
  aws_account_id "XXXX-XXXX-XXXX"
  aws_access_key "XXXXXXXXXXXXXXXXXXXX"
  aws_secret_access_key "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
  chef_bucket "maestro-example.yourdomain.com"

  roles do
    role "allinone" do
      public_ports [80, 443]
    end
  end

  nodes do
    ec2_node "web-1" do
      roles ["allinone"]
      ami "ami-2d4aa444" # ubuntu 10.04
      ssh_user "ubuntu"
      instance_type "m1.small"
      availability_zone "us-east-1b"
      cookbook_attributes <<-COOKBOOK_ATTRIBUTES
        "rails_version": "3.0.0",
        "rails_env": "staging",
        "database_name": "maestrorails3example_staging",
        "database_user": "web",
        "database_password": "web",
        "public_hostname": "www.staging.yourdomain.com",
        "nginx": {
          "worker_connections": "2048",
          "app_root": "/mnt/apps/maestro-rails3-example/current"
        },
        "mysql": {
          "server_root_password": "XXXXXXXXXXXX"
        },
        "mysql_ebs": {
          "device": "/dev/sdh",
          "mount_dir": "/vol/ebs",
          "ebs_volume_id": "vol-XXXXXXXX",
          "aws_access_key_id": "XXXXXXXXXXXXXXXXXXXX",
          "aws_secret_access_key": "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
        },
        "postfix": {
          "mydomain": "yourdomain.com",
          "relayhost": "mail.authsmtp.com",
          "relayport": "23",
          "relayuserid": "XXXXXXX",
          "relaypassword": "XXXXXXXXXXXXXX",
          "relay_concurrent_connections": "5"
        },
        "monit": {
          "alert_email_address": "XXXXX@XXXXXX.com",
          "from_email_address": "monit@yourdomain.com"
        }
      COOKBOOK_ATTRIBUTES
      elastic_ip "XXX.XXX.XXX.XXX"
      ebs_volume_id "vol-XXXXXXXX"
      ebs_device "/dev/sdh"
    end
  end
end
