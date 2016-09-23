# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  #avoid perl warnings on puppet runs from fruit-that-shall-not-be-named systems
  config.vm.provision "shell", 
    inline: "perl -pi -e 's/127\.0\.1\.1\slocalhost\.vm\slocalhost/127\.0\.1\.1\tlocalhost\.vm\tlocalhost\t#{config.vm.box}/' /etc/hosts ; egrep '^33.33.33.[0-9]+ puppet' /etc/hosts || echo '33.33.33.200 puppet puppet.vagrant.test.jppol.net' >> /etc/hosts"
  ENV["LC_ALL"] = "en_US.UTF-8"
  config.vm.provider "virtualbox" do |v|
    v.memory = 512
    v.cpus = 1
  end

  config.vm.define "puppet" do |puppet| 
    puppet.vm.box = "puppetlabs/ubuntu-16.04-64-puppet"
    puppet.vm.hostname = "puppet.test.vagrant.rootdom.dk"
    puppet.vm.network "private_network", ip: "33.33.33.200"
    puppet.vm.provision "puppet" do |puppet|
      #puppet.options = ""
      #puppet.options = "-v"
      #puppet.options = "-v -d"
      puppet.environment_path = "./puppet/environments"
      puppet.environment = "test"
    end
  end

  config.vm.define "client01" do |client01| 
    client01.vm.box = "puppetlabs/ubuntu-16.04-64-puppet"
    client01.vm.network "private_network", ip: "33.33.33.2"
    client01.vm.hostname = "client01.test.vagrant.jppol.net"
    client01.vm.provision "puppet_server" do |puppet_agent|
      puppet_agent.binary_path = "/opt/puppetlabs/bin"
      puppet_agent.options = "--environment=testing"
    end
  end

  config.vm.define "client02" do |client02| 
    client02.vm.box = "puppetlabs/ubuntu-16.04-64-puppet"
    client02.vm.network "private_network", ip: "33.33.33.3"
    client02.vm.hostname = "client02.test.vagrant.jppol.net"
    client02.vm.provision "puppet_server" do |puppet_agent|
      puppet_agent.binary_path = "/opt/puppetlabs/bin"
      puppet_agent.options = "--environment=testing"
    end
  end
end
