class php5::pgsql {
    package { ["php5-pgsql"]:
        ensure => latest,
        require => Package["php5-cli"],
    }
}
