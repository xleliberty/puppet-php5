class php5::php54dotdeb {
    file { "dotdeb.list":
        path => "/etc/apt/sources.list.d/dotdeb.list",
        ensure => file,
        owner => "root",
        group => "root",
        content => "deb http://packages.dotdeb.org stable all\ndeb-src http://packages.dotdeb.org stable all",
        notify => Exec["dotDebKeys"]
    }

    exec { "dotDebKeys":
        command => "wget -q -O - http://www.dotdeb.org/dotdeb.gpg | sudo apt-key add -",
        path => ["/bin", "/usr/bin"],
        notify => Exec["aptGetUpdate"],
        unless => "apt-key list | grep dotdeb"
    }

    package { ["php5-apc", "php5-xhprof"]:
        ensure => latest,
        require => Package["php5-cli"],
    }

    package { ["phpapi-20090626", "php-apc"]:
        ensure => purged,
    }
}
