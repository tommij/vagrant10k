class localvagrantpuppet () {
  class { "localvagrantpuppet::dpkg_policy_overrides": 
    stage => 'first',
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
  file { "/etc/puppetlabs/r10k/r10k.yaml":
    ensure => present,
    owner => root,
    group => puppet,
    mode => "0640",
    require => Package['r10k'],
    source => "puppet:///modules/localvagrantpuppet/r10k/r10k.yaml"
  }
  file { "/etc/puppetlabs/puppet/puppet.conf":
    ensure => present,
    owner => root,
    group => root,
    mode => "0644",
    source => "puppet:///modules/localvagrantpuppet/puppet/puppet.conf",
    notify => Service['puppetserver']
  }
  sshkey { "local vagrant key": 
    name => localhost,
    ensure => present,
    key => $facts['ssh']['ed25519']['key'],
    type => 'ed25519'
  }
  sshkey { "github-rsa":
    name => "github.com",
    ensure => "present",
    key => "AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==",
    type => "ssh-rsa"
  }
  class { "pushadminrepo": 
    stage => 'last',
  }


} 

class pushadminrepo { 
  exec {'push base admin repo':
    command => '/usr/bin/git clone https://github.com/tommij/gitolite_admin_skel.git',
    cwd => '/tmp/',
    refreshonly => true,
    require =>   Sshkey['local vagrant key'],
    creates => "/var/lib/gitolite3/.gitolite/keydir/vagrant.pub",
    subscribe => Package['gitolite3'],
    notify => Exec['push base admin repo 2']
  }
  exec {'push base admin repo 2':
    cwd => '/tmp/gitolite_admin_skel',
    refreshonly => true,
    command => '/usr/bin/git remote add localhost git@localhost:gitolite-admin && git push --force localhost && cd .. ; rm -rf gitolite_admin_skel',
    notify => Exec['git localpuppet']
  }
  exec {'git localpuppet':
    cwd => '/tmp/',
    refreshonly => true,
    command => '/usr/bin/git clone https://github.com/tommij/localpuppet && cd localpuppet && git fetch --all && git remote add localhost git@localhost:localpuppet && git push localhost --all && cd .. && rm -rf localpuppet',
  }

}

class localvagrantpuppet::dpkg_policy_overrides () {
  file { "/usr/sbin/policy-rc.d":
    ensure => present,
    source => "puppet:///modules/localvagrantpuppet/usr/sbin/policy-rc.d",
    mode   => "0755",
    owner  => root,
    group  => root
  }
}
