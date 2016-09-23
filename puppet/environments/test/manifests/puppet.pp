node "puppet" {
  include defaults 
  class { "puppetserver":
  } 
  class { "localvagrantpuppet": 
  }
}
