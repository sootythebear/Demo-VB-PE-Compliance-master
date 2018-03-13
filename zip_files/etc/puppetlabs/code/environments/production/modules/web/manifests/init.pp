class web {

  $pack = $::osfamily ? {
    redhat => httpd,
    debian => apache2,
  }

  package { "${pack}" :
    ensure => present,
  }

  file { '/var/www/html/index.html' :
    ensure => file,
    source => 'puppet:///modules/web/index.html',
    require => Package["${pack}"],
  }

  service { "${pack}" :
    ensure => running,
    enable => true,
    subscribe => File["/var/www/html/index.html"],
  }

# Set variable to IP address of one of the NIC cards
#  $ip_address = $::facts['networking']['interfaces']['enp0s8']['ip']

# Show the web address
#  notify { "The web url is: ${ip_address}":
#  }
}
