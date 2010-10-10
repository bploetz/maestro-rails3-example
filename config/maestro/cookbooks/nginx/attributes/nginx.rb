set_unless[:passenger][:version]  = "2.2.15"
set_unless[:nginx][:version]      = "0.7.65"

set[:nginx][:dir]                 = "/opt/nginx"
set[:nginx][:src_binary]   = "#{nginx[:dir]}/sbin/nginx"
set[:nginx][:conf_dir] = "#{nginx[:dir]}/conf"
set[:nginx][:ssl_dir]  = "#{nginx[:dir]}/ssl"
set[:nginx][:pid_dir] = "/var/run/nginx"
set[:nginx][:pid_path] = "/var/run/nginx/nginx.pid"
set[:nginx][:log_dir]  = "/mnt/log/nginx"
set[:nginx][:user]     = "nginx"
set[:nginx][:group]     = "nginx"
set[:nginx][:binary]   = "#{nginx[:dir]}/sbin/nginx"

set_unless[:nginx][:configure_flags] = [
  "--prefix=#{nginx[:dir]}",
  "--pid-path=#{nginx[:pid_path]}",
  "--with-http_ssl_module",
  "--with-http_gzip_static_module",
  "--with-http_flv_module",
  "--with-http_stub_status_module",
  "--add-module=$(passenger-config --root)/ext/nginx"
]

set_unless[:nginx][:gzip] = "on"
set_unless[:nginx][:gzip_http_version] = "1.0"
set_unless[:nginx][:gzip_comp_level] = "2"
set_unless[:nginx][:gzip_proxied] = "any"
set_unless[:nginx][:gzip_types] = [
  "text/plain",
  "text/html",
  "text/css",
  "application/x-javascript",
  "text/xml",
  "application/xml",
  "application/xml+rss",
  "text/javascript"
]

set_unless[:nginx][:keepalive]          = "on"
set_unless[:nginx][:keepalive_timeout]  = 65
set_unless[:nginx][:worker_processes]   = cpu[:total]
set_unless[:nginx][:worker_connections] = 2048
set_unless[:nginx][:server_names_hash_bucket_size] = 64
