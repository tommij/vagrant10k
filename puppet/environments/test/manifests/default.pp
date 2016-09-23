node "default" {
  include defaults
}

class defaults { 
  include stages
  class { "firststage": 
    stage => "first"
  }
  class { "default_packages": 
    stage => "second"
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

class firststage () {
  apt::source { 'puppetlabs':
    location => 'http://apt.puppetlabs.com',
    repos    => 'main',
    key      => {
      'id'     => '6F6B15509CF8E59E6E469F327F438280EF8D349F',
      'server' => 'pgp.mit.edu',
    }
  }
  class { 'apt':
    stage => first,
    update => {
    frequency => 'daily',
    },
  }

}
