Vagrant.configure("2") do |config|
  config.vm.hostname = "drupal-cookbook"
  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"
  config.vm.network :private_network, ip: "33.33.33.10"
  config.ssh.forward_agent = true
  config.ssh.max_tries = 40
  config.ssh.timeout   = 120
  config.omnibus.chef_version = "11.10.4"
  config.berkshelf.enabled = true
  config.vm.provision :chef_solo do |chef|
    chef.json = {
     :www_root => '/vagrant/public',
     :mysql => {
        :server_root_password => "randompassword",
        :server_repl_password => "randompassword",
        :server_debian_password => "randompassword"
     },
     :drupal => {
        :db => {
          :password => "randompassword"
        },
        :dir => "/vagrant/drupal-site"
      },
      :hosts => {
        :localhost_aliases => ["drupal.vbox.local", "dev-site.vbox.local"]
      }
    }
    chef.run_list = [
      "recipe[drupal::default]"
    ]
  end
end
