node "default" {
  include defaults
}

class defaults { 
  include stages
  class { "default_packages": 
    stage => "second"
  }
  class { "stupid_apt_update": 
    stage => "first"
  }
  #debug
  file { "/tmp/default": 
    ensure => present,
    content => "foo"
  }
}

class stages { 
  stage { 'first': }
  stage { 'second': }
  stage { 'third': }
  stage { 'last': }
  Stage['first'] -> Stage['second'] -> Stage['third'] -> Stage['main'] -> Stage['last']
}

class default_packages {
  $default_packages = [ "vim","psmisc","sysdig","sysdig-dkms","openssl" ]
  package { 
    $default_packages: ensure => latest,
  }
}

class stupid_apt_update {
  exec { "/usr/bin/apt-get update": } 
}
