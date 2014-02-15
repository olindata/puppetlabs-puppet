class puppet::common($puppet_server = $::puppet::params::puppet_server) inherits puppet::params {
    concat::fragment { 'puppet.conf-common':
      order   => '00',
      target  => $puppet_conf,
      content => template("puppet/puppet.conf-common.erb"),
    }
}