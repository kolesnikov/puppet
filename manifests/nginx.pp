# Class: cmantix/nginxphp::nginx
#
# Install Nginx.
#
# Parameters:
# 
# Actions:
#   Install nginx and make sure it's running.
# 
# Requires:
#   nginxphp
#
# Sample Usage:
#     include nginxphp::nginx
#
class nginxphp::nginx {
  
  service { 'nginx':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => Package["nginx"],
    restart    => '/etc/init.d/nginx reload'
  }

  # disable default configuration
  file { 'default-nginx-disable':
    path    => '/etc/nginx/sites-enabled/default',
    ensure  => absent,
    notify  => Service['nginx'],
    require => Package['nginx']
  }
}

# Function: nginxphp::nginx_addphpconfig
#
# Install Nginx.
#
# Parameters:
#     $website_host [default:] Host address.
#     $config_template [default:nginxphp/nginx.php.conf.erb] Configuration template for the nginx configuration.
# 
# Actions:
#   Install config for a PHP site.
# 
# Requires:
#   nginxphp:nginx
#
# Sample Usage:
#     nginxphp::nginx_addphpconfig {
#       "my-nginx-conf":
#          config_template    => "nginxphp/nginx.php.conf.erb"
#     }
#
define nginxphp::nginx_addphpconfig (
  $config_template    = "nginxphp/nginx.php.conf.erb") {
  file { "nginx-conf-${name}":
    path    => "/etc/nginx/sites-available/${name}.conf",
    owner   => 'root',
    group   => 'root',
    mode    => 644,
    require => Package['nginx'],
    content => template("nginxphp/nginx.php.conf.erb")
  }

  file { "nginx-conf-link-${name}":
    path    => "/etc/nginx/sites-enabled/${name}.conf",
    target  => "/etc/nginx/sites-available/${name}.conf",
    ensure  => link,
    notify  => Service['nginx'],
    require => [File["nginx-conf-${name}"], File['default-nginx-disable'], Package['php5-fpm']]
  }
}
