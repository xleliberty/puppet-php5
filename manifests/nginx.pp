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
class php5::nginx {
  include php5::removeApache
  package { 'nginx-full' :
    ensure  => present,
    require => Class['php5::removeApache']
  }

  service { 'nginx' :
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => Package["nginx-full"],
    restart    => '/etc/init.d/nginx reload'
  }

  # disable default configuration
  file { 'default-nginx-disable':
    path    => '/etc/nginx/sites-enabled/default',
    ensure  => absent,
    notify  => Service['nginx'],
    require => Package['nginx-full']
  }

  file { '/home/log/nginx' :
      ensure => directory,
      owner => www-data,
      group => root,
      mode => 755
  }
}

# Function: nginxphp::nginx_addphpconfig
#
# Install Nginx.
#
# Parameters:
#     $website_host [default:cmantix.dev.local] Host address.
#     $website_root [default:/var/www/] Website root path.
#     $default_controller [default:index.php] Controller file.
#     $php_pool_addr [default:127.0.0.1:9002] Address of the pool.
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
#          website_host       => "cmantix.dev.local",
#          website_root       => "/var/www/",
#          default_controller => "index.php",
#          php_pool_addr      => "127.0.0.1:9002",
#          config_template    => "nginxphp/nginx.php.conf.erb"
#     }
#
define php5::nginx_addphpconfig (
  $website_host       = "eliberty.dev.local",
  $website_root       = "/vagrant/web/",
  $default_controller = "app_dev.php",
  $php_pool_addr      = "/var/run/php-fpm/php-fpm.sock",
  $config_template    = "php5/nginx.php.conf.erb") {
  file { "nginx-conf-${name}":
    path    => "/etc/nginx/sites-available/${name}.conf",
    owner   => 'root',
    group   => 'root',
    mode    => 644,
    require => Package['nginx-full'],
    content => template("php5/nginx.php.conf.erb")
  }

  file { "nginx-conf-link-${name}":
    path    => "/etc/nginx/sites-enabled/${name}.conf",
    target  => "/etc/nginx/sites-available/${name}.conf",
    ensure  => link,
    notify  => Service['nginx'],
    require => [File["nginx-conf-${name}"], File['default-nginx-disable'], Package['php5-fpm']]
  }
}

# Class: nginxphp::removeApache
#
# Remove Apache ... PLEASE
#
# Parameters:
#
# Actions:
#    Remove apache packages from the server ... we are using Nginx here ...
#
# Requires:
#    nginxphp
#
# Sample Usage:
#     include nginxphp::nginxphp
#
class php5::removeApache {
  $apachePackages = ["apache2-mpm-prefork", "apache2-utils", "apache2.2-bin", "apache2.2-common", "libapache2-mod-php5filter"]
  package { $apachePackages: ensure => absent, }
}
