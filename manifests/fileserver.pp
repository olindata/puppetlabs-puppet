class puppet::fileserver {

  ::concat { '/etc/puppet/fileserver.conf':
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  ::concat::fragment { 'puppet_fileserver_conf_header':
    target  => '/etc/puppet/fileserver.conf',
    order   => 00,
    source => 'puppet:///modules/puppet/fileserver-header.conf',
  }
}
