maintainer        "bploetz"
description       "Configures monit"
version           "0.1.0"

attribute "monit/alert_email_address",
  :display_name => "Monit alert email address",
  :description => "Email address that monit alerts are sent to",
  :default => ""

attribute "monit/from_email_address",
  :display_name => "Monit alert from email address",
  :description => "From email address for monit alerts",
  :default => ""
