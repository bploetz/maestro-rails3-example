maintainer        "Opscode, Inc."
maintainer_email  "cookbooks@opscode.com"
license           "Apache 2.0"
description       "Installs and configures postfix for client or outbound relayhost, or to do SASL auth"
version           "0.8"
recipe            "postfix::sasl_auth", "Set up postfix to auth to a server with sasl"

%w{ubuntu debian}.each do |os|
  supports os
end

attribute "postfix",
  :display_name => "Postfix",
  :description => "Hash of Postfix attributes",
  :type => "hash"

attribute "postfix/mydomain",
  :display_name => "Postfix Mydomain",
  :description => "Sets the mydomain value in main.cf",
  :default => "domain"

attribute "postfix/relayhost",
  :display_name => "Postfix Relayhost",
  :description => "Sets the relayhost value in main.cf",
  :default => ""

attribute "postfix/relayport",
  :display_name => "Postfix Relayhost's Port",
  :description => "Sets the relayhost's port value in main.cf",
  :default => ""

attribute "postfix/relayuserid",
  :display_name => "Postfix Relay User ID",
  :description => "Sets the user id to authenticate with the relayhost in main.cf",
  :default => ""

attribute "postfix/relaypassword",
  :display_name => "Postfix Relay User Password",
  :description => "Sets the password to authenticate with the relayhost in main.cf",
  :default => ""

attribute "postfix/relay_concurrent_connections",
  :display_name => "Postfix Relay Concurrent Connections",
  :description => "Max number of connections to the relay host in main.cf",
  :default => ""
