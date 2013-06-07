class php5::fpm($php_packages){

    $fpm_init_name = 'php5-fpm'

    package { 'php5-fpm' :
        ensure => latest,
        require => Package["php5-cli"],
    }

    service { 'php5-fpm' :
          ensure => running,
          enable => true,
          hasrestart => true,
          hasstatus   => true,
          require => Package['php5-fpm'],
          restart => "/etc/init.d/${fpm_init_name} restart"
    }

    # remove fpm default pool
    file { 'fpm-disable-default' :
      path => '/etc/php5/fpm/pool.d/www.conf',
      ensure => absent,
      notify => Service['php5-fpm'],
      require => Package['php5-fpm']
    }


  # install all required packages
  package {
    $php_packages :
      ensure => latest,
      notify => Service["php5-fpm"],
  }
}

# Function: cmantix/nginxphp::fpmconfig
#
# Set FPM pool configuration
#
# Parameters:
#   $php_devmode [default:false]  Enable debug logging and .
#   $fpm_user    [default:www-data] User that runs the pool.
#   $fpm_group   [default:www-data] Group that runs the pool.
#   $fpm_listen  [default:127.0.0.1:9002] IP and port that the pool runs on.
#   $fpm_allowed_clients [default:127.0.0.1] Client ips that can connect to the pool.
#
# Actions:
#    install php-fpm pool configuration
#
# Requires:
#    nginxphp::php
#
# Sample Usage:
#     nginxphp::fpmconfig { 'bob':
#       php_devmode   => true,
#       fpm_user      => 'vagrant',
#       fpm_group     => 'vagrant',
#       fpm_allowed_clients => ''
#     }
#
define php5::fpmconfig (
        $php_devmode         = false,
        $fpm_user            = 'www-data',
        $fpm_group            = 'www-data',
        $fpm_listen          = '127.0.0.1:9002',
        $fpm_allowed_clients = '127.0.0.1'
  ){
  # set config file for the pool
  file {"fpm-pool-${name}":
    path => "/etc/php5/fpm/pool.d/${name}.conf",
    owner   => 'root',
    group   => 'root',
    mode    => 644,
    notify  => Service['php5-fpm'],
    require => Package['php5-fpm'],
    content => template("php5/pool.conf.erb")
  }

   file { '/home/log/php' :
      ensure  => directory,
      owner   => "${fpm_user}",
      group   => "${fpm_user}",
      mode    => 755,
      require => Package['php5-fpm']
    }

}
