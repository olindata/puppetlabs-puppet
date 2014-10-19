require 'beaker-rspec'

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Enable colour
  c.tty = true

  # This is where we 'setup' the nodes before running our tests
  c.before :suite do
    hosts.each do |host|
      # Install puppet
      install_puppet()

      osfamily = on(host, facter('osfamily')).stdout.strip

      puppet_module_install(:source => proj_root, :module_name => 'puppet')
      # Install dependencies from Modulefile
      shell("echo '127.0.0.1 master.test.local' >> /etc/hosts")
      shell('hostname master.test.local')
      shell('puppet module install puppetlabs-inifile')
      shell('puppet module install puppetlabs-apache')
      shell('puppet module install puppetlabs-puppetdb')
      shell('puppet module install puppetlabs-stdlib')
      if osfamily == 'Debian'
        shell('puppet module install puppetlabs-apt')
      end
      # puppetlabs-apache requires EPEL for mod_passenger
      if osfamily == 'RedHat'
        shell('puppet module install stahnma-epel')
        apply_manifest_on agent, 'class {"epel": }', { :catch_failures => true }
      end
    end
  end
end
