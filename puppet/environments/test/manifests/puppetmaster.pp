node "puppetmaster" {
  include defaults 



  $git_admin_user = "admin_tlj"
  $git_public_key = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEsiludoo1Y/ihcY/GpgcjHxVacm8uMQMlfxM7IiHXn15k1bVkwhQVmkBGiq23qgtyrMdKbWQYdAGdtA3OPBL6w= tommi@blackgronk"

  $git_home = "/var/lib/gitolite3"
  package{ ["gitolite3"]: 
    ensure => latest, 
    notify => Exec["setup-gitolite"]
  }
  user { "git": name => "git", ensure => present, managehome => true, home => $git_home }
  file { "/tmp/${git_admin_user}.pub":
    ensure => present,
    content => "$git_public_key"
  }
  exec { "setup-gitolite":
    command => "/usr/bin/gitolite setup -pk /tmp/${git_admin_user}.pub",
    creates => "/home/git/.gitolite.rc",
    environment => "HOME=${git_home}",
    user    => "git",
    group   => "git",
    returns => 0,
    refreshonly => true,
    require => [ Package["gitolite3"], User["git"], File["/tmp/$git_admin_user.pub"] ],
  }
  package { ["default-jre", "puppetserver"]: 
    ensure => present,
    notify => [ File["/tmp/${git_admin_user}.pub"] ]
   # notify => [ Exec["setup-r10k"], File["/tmp/${git_admin_user}.pub"] ]
  }
  file { "/usr/local/bin/gem": 
    ensure => link,
    target => "/opt/puppetlabs/puppet/bin/gem"
  }
  #yes, I know it's fugly, have nowhere apparant to store it.
  file { "unsecure-puppet-pem": 
    path => "/etc/puppetlabs/puppet/ssl/certs/puppetmaster.rootdom.dk.pem",
    ensure => link,
    target => "/etc/puppetlabs/puppet/ssl/certs/ca.pem",
    require => Package['puppetserver']
  }
  file { "/etc/default/puppetserver": 
    ensure => present,
    require => Package['puppetserver'],
    content => "JAVA_BIN=\"/usr/bin/java\"\nJAVA_ARGS=-Xms128m -Xmx128m -XX:MaxPermSize=256m\nUSER=\"puppet\"\nGROUP=\"puppet\"\nINSTALL_DIR=\"/opt/puppetlabs/server/apps/puppetserver\"\nCONFIG=\"/etc/puppetlabs/puppetserver/conf.d\"\nBOOTSTRAP_CONFIG=\"/etc/puppetlabs/puppetserver/services.d/,/opt/puppetlabs/server/apps/puppetserver/config/services.d/\"\nSERVICE_STOP_RETRIES=60\n"
  }
  service { "puppetserver": 
    ensure => running, 
    enable => true,
    require => [ File['/etc/default/puppetserver'], File['unsecure-puppet-pem'] ],
  }
  file { "/opt/puppetlabs/r10k": 
    ensure => directory,
    owner => root,
    group => root,
    require => Package['puppetserver']
  }
  file { "/opt/puppetlabs/r10k/cache": 
    ensure => directory,
    owner => root,
    group => root,
    require => File['/opt/puppetlabs/r10k']
  }
  package { "r10k": 
    ensure => latest,
    provider => gem,
    require => [ File['/opt/puppetlabs/r10k/cache/'], File['/usr/local/bin/gem'] ] 
  }
#  file { "

}


#    content => "JAVA_BIN=\"/usr/bin/java\"\nJAVA_ARGS=-Xms128m -Xmx128m -XX:MaxPermSize=256m\nUSER=\"puppet\"\nGROUP=\"puppet\"\nINSTALL_DIR=\"/opt/puppetlabs/server/apps/puppetserver\"\nCONFIG=\"/etc/puppetlabs/puppetserver/conf.d\"\nBOOTSTRAP_CONFIG=\"/etc/puppetlabs/puppetserver/services.d/,/opt/puppetlabs/server/apps/puppetserver/config/services.d/\"\nSERVICE_STOP_RETRIES=60\n"
