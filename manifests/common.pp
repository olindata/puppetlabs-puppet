class puppet::common($user_id, $group_id) inherits puppet::params {
  user { 'puppet':
    ensure => present,
    uid    => $user_id,
    gid    => 'puppet',
  }

  group { 'puppet':
    ensure => present,
    gid    => $group_id,
  }

  file { $confdir:
    ensure       => directory,
    group        => 'puppet',
    owner        => 'puppet',
    recurse      => true,
    recurselimit => '1',
  }

  concat { $puppet_conf: mode => '0644', }

  concat::fragment { 'puppet.conf-common':
    order   => '00',
    target  => $puppet_conf,
    content => template("puppet/puppet.conf-common.erb"),
  }

}