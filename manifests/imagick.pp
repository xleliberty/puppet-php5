class php5::imagick {
    package { ["php5-imagick"]:
        ensure => latest,
        require => Package["php5-cli"],
    }
}
