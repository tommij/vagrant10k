class localvagrantpuppet () {
  exec{'push base admin repo':
    command => '/usr/bin/git push --force localhost master',
    cwd => '/tmp/vagrant-puppet/environments/fuglyhack/git-repos/gitolite-admin',
    refreshonly => true,
    require =>   Sshkey['local vagrant key'],
    creates => "/var/lib/gitolite3/.gitolite/keydir/vagrant.pub"
  }
} 
