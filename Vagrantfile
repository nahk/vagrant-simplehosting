# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

###############################
# General project settings
# -----------------------------
box_name = "chef/debian-7.4"
box_memory = "1024"
ip_address = "192.168.10.10"

# Project type (available are: "auto", "symfony")
architecture = "auto"

# -----------------------------
###############################

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = box_name

  config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm", :id, "--memory", box_memory]
  end

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network "private_network", ip: ip_address

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # If true, then any SSH connections made will enable agent forwarding.
  # Default value: false
  config.ssh.forward_agent = true

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"


  # Provisioning
  config.vm.provision "shell" do |s|
    s.path = "https://raw.githubusercontent.com/CestanGroupeNumerique/vagrant-simplehosting/master/provision/bootstrap.sh"
    s.args = architecture
    s.privileged = true
  end

  config.vm.provision "shell", run: "always" do |s|
    s.path = "https://raw.githubusercontent.com/CestanGroupeNumerique/vagrant-simplehosting/master/provision/always.sh"
    s.privileged = true
  end
end
