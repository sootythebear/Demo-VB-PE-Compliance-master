class web::remove {

  $pack = $::osfamily ? {
    redhat => httpd,
    debian => apache2,
  }

  package { "${pack}" :
    ensure  => absent,
    require => File["/var/www/html/index.html"],
  }

  file { '/var/www/html/index.html' :
    ensure => absent,
    require => Service["${pack}"],
  }

  service { "${pack}" :
    ensure  => stopped,
    enable  => false,
  }
}
