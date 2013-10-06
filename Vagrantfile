# This Vagrantfile helps configure the Backend application for 3scale
# You can deploy each node that allows 3scale to do the magic.
#
# Each node should have this parameters:
#  *box*             => Vagrant box name that is going to be used to build the instance.
#  *box_url*         => Vagrant URL to download the box (This can be overriden if you want to use the base box ).
#  *name*            => Vagrant Box name.
#  *domain*          => Development domain test the app.
#  *fqdn*            => FQDN of each machine.
#  *ip*              => Desired IP for each box.
#  *puppet_options*  => Puppet Options for each box, ensure debug and verbose.
#  *memory*          => Minimum memory for each instances (Depends on the host).
#  *manifest_file*   => The manifest on which are modules declared for each instance
#Define each configuration in a ruby hash
VAGRANTFILE_API_VERSION = "2"

servers = { "vagrantbox" => { "box"            => "base",
                              "box_url"        => "http://files.vagrantup.com/precise64.box",
                              "cpu"            => "1",
                              "environment"    => "devel".
                              "name"           => "vagrantbox",
                              "domain"         => "dev.local",
                              "fqdn"           => "vagrantbox.dev.local",
                              "ip"             => "192.168.50.4",
                              "memory"         => "512",
                              "manifest_file"  => "box.pp"},
          }

# Here's a quick breakdown on what the single letter objects mean.
# b - box configuration
# c - imported configuration (value in hash above)
# s - server (key in hash above)
# v - vagrant

Vagrant.configure(VAGRANTFILE_API_VERSION) do |v|

  # For each configuration from the hash above:
  servers.each do |s, c|

    #Define a vagrant instance and do box configuration
    v.vm.define s do |b|

      # Determine which box to use
      if c.has_key?("box")
          b.vm.box = c["box"]
          b.vm.box_url = c["box_url"]
      else
          b.vm.box = "base"
          b.vm.box_url = "http://files.vagrantup.com/precise64.box"
      end

      # Determine the IP Box
      if c.has_key?("ip")
        b.vm.network :private_network, ip: c["ip"]
      end

      # Define forwarded ports
      if c.has_key?("ports")
        c['ports'].each do |f, d|
          b.vm.network "forwarded_port", guest: d.to_i, host: f.to_i
        end
      end

      # Configure provider specific information
      if c.has_key?("cpu") and
          c.has_key?("memory")
            b.vm.provider :virtualbox do |vb|
            vb.customize ["modifyvm", :id, 
                          "--cpuexecutioncap", "40",
                          "--cpus", c['cpu'],
                          "--memory", c['memory'],
                          "--name", c['name']]
            end
      end

      #Install puppet 3
      b.vm.provision :shell, :path => "scripts/bootstrap.sh"

      # Added shell provisioning.
      b.vm.provision :shell, :inline => "apt-get update"

      # Ensure puppet 3 is installed
      b.vm.provision :shell, :inline => "apt-get -y install puppet"

      # Install Basic plugins
      b.vm.provision :shell, :inline => "apt-get -y install build-essential"

      # Install The Editor
      b.vm.provision :shell, :inline => "apt-get -y install vim"

      # Install SCMs
      b.vm.provision :shell, :inline => "apt-get -y install git"

      # Install Tools
      b.vm.provision :shell, :inline => "apt-get -y install curl"

      # Added puppet provisioner
      b.vm.provision :puppet do |puppet|
        puppet.manifests_path = "manifests"
        puppet.manifest_file  = c['manifest_file']
        puppet.module_path    = "modules"
        puppet.hiera_config_path   = "config/hiera.yaml"
        puppet.temp_dir            = "/tmp/vagrant-puppet"
        puppet.working_directory   = "/vagrant/hieradata"
        puppet.options = "--verbose --debug --summarize --environment #{c['environment']}"
        puppet.facter         = {
          "vagrant"   => c['vagrant_id'],
          "fqdn"      => c['fqdn'],
          "ipaddress" => c['ip'],
          # Vm will override this value depending on your resolv.conf of the host.
          # check your system preferences => network.
          "domain"    => c['domain']
        }
      end
    end
  end
end
