define puppet::fileserver::section ($path, $allow, $deny = undef) {
  include ::puppet::fileserver

  ::concat::fragment { "puppet_fileserver_section_${name}":
    target  => '/etc/puppet/fileserver.conf',
    order   => 05,
    content => template('puppet/fileserver-section.conf.erb'),
  }

}
