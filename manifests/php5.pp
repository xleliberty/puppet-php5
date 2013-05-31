class php5::php5 {
    package { "php5-cli":
        ensure => latest,
        require => Exec["aptGetUpdate"],
    }

    package { ["php5-xdebug", "php5-intl", "php5-sqlite", "php5-curl"]:
        ensure => latest,
        require => Package["php5-cli"],
    }

    package { "php5-suhosin":
        ensure => purged,
        require => Package["php5-cli"],
    }

    file { "php-xdebug.ini":
        path => "/etc/php5/conf.d/20-xdebug.ini",
        ensure => file,
        content => template("php5/php-xdebug.ini"),
        require => Package["php5-cli"]
    }

    file { "php-timezone.ini":
        path => "/etc/php5/conf.d/30-timezone.ini",
        ensure => file,
        content => template("php5/php-timezone.ini"),
        require => Package["php5-cli"]
    }

    $sysPackages = ["build-essential", "curl"]
    package { $sysPackages :
        ensure => "latest",
    }
}
