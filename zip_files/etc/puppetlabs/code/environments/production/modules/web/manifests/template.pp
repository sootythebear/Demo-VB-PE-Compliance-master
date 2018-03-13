class web::template {

  $pack = $::osfamily ? {
    redhat => httpd,
    debian => apache2,
  }

  package { "${pack}" :
    ensure => present,
  }

# Obtain the hostname from Facter and assign as a variable
# to be passed to the File -> template
  $hostname = $::hostname

  file { '/var/www/html/index.html' :
    ensure => file,
#    source => 'puppet:///modules/web/index.html',
    content => template('web/index.html.erb'),
    require => Package["${pack}"],
  }

  service { "${pack}" :
    ensure => running,
    enable => true,
    subscribe => File["/var/www/html/index.html"],
  }

# Set variable to IP address of one of the NIC cards
  $ip_address = $::facts['networking']['interfaces']['enp0s8']['ip']

# Show the web address
  notify { "The web url is: ${ip_address}":
  }
}
