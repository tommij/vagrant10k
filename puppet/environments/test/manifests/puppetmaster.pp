node "puppetmaster" {
  include defaults 



  $git_public_key = "AAAAB3NzaC1yc2EAAAADAQABAAABAQDQa0LR6AdH+FrM3s0jE3vt57ZfgDiwGCnDt2NU3dWcU43+uyAKWlTd+0Fqb5jhZzspCDHoxklkV+HGcs8ECPcmQEEqkn2/5PYo8gLqVsGN0UCSvoONyl1SeCEvYKtQ6d1ZnPnqnuI5bI6JX09CQ0U5vr2u4F21CcB6wz5ubSHiWucesA7Yu1tRqdkv5oihknjdeZYhOl2GUKT87e3fdsqR6YW/L6WDV/PDzpCnl5HN2EqHmxhbfdWP3DVPZmIfc/J1jlv9EF4u7lUmbtDoSRwmtrRyrjJxMW/AUxoFq5ZXB8GAdcIyQt53alxuNc3IrVKFbZLAUJrGhbA0nkp5lt2P"
  class { "gitolite": 
    git_key => $git_public_key,
    git_key_type => ssh-rsa,
    git_home => "/var/lib/gitolite3",
    custom_rc => true,
    notify => Exec['push base admin repo']
    #r10k_update => true
  }
  package { ["default-jre", "puppetserver"]: 
    ensure => present,
   # notify => [ File["/tmp/${git_admin_user}.pub"] ]
   # notify => [ Exec["setup-r10k"], File["/tmp/${git_admin_user}.pub"] ]
  }
  file { "/usr/local/bin/gem": 
    ensure => link,
    target => "/opt/puppetlabs/puppet/bin/gem"
  }
  file { "/usr/local/bin/r10k": 
    ensure => link,
    target => "/opt/puppetlabs/puppet/bin/r10k"
  }

  #yes, I know it's fugly, have nowhere apparant to store it at present.
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
  file { "/root/.ssh": 
    ensure => directory,
    owner => 'root',
    mode => '0700'
  }
  file { "/root/.ssh/id_rsa": 
    ensure => present,
    source => "puppet:///modules/localvagrantpuppet/ssh_keys/id_rsa",
  
    mode => '0600',
    require => File['/root/.ssh']
  }
  file { "/root/.ssh/id_rsa.pub": 
    ensure => present,
    source => "puppet:///modules/localvagrantpuppet/ssh_keys/id_rsa.pub",
    mode => '0600',
    require => File['/root/.ssh']
  }
  file { "/etc/puppetlabs/r10k":
    ensure => directory,
    owner => root,
    group => puppet,
    mode => "0750"
  }
  file { "/etc/puppetlabs/r10k/r10k.yaml":
    ensure => present,
    owner => root,
    group => puppet,
    mode => "0640",
    source => "puppet:///modules/localvagrantpuppet/r10k/r10k.yaml"
  }
  class { "localvagrantpuppet": 
    stage => last
  }
  notify { $facts['ssh']['ed25519']['key']:}
  sshkey { "local vagrant key": 
    name => localhost,
    ensure => present,
    key => $facts['ssh']['ed25519']['key'],
    type => 'ed25519'
  }
}
