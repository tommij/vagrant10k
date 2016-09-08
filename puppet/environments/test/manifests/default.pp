node "default" {
  include defaults
}

class defaults { 
  include stages
  class { "default_packages": 
    stage => "second"
  }
  #package mangement
  class { 'apt':
    stage => first,
    update => {
    frequency => 'daily',
    },
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

