# Class: puppet::agent
#
# This class installs and configures the puppet agent
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class puppet::agent (
  $puppet_server,
  $environment          = $::puppet::params::environment,
  $puppet_defaults      = $::puppet::params::puppet_defaults,
  $puppet_agent_service = $::puppet::params::puppet_agent_service,
  $puppet_agent_name    = $::puppet::params::puppet_agent_name,
  $puppet_conf          = $::puppet::params::puppet_conf,
  $package_provider     = undef,
  $reporting            = true,
  $version              = 'present',
  $puppet_agent_enabled = true,
  $puppet_run_style     = 'service',
  $puppet_run_interval  = 30,
  $user_id              = undef,
  $group_id             = undef,) inherits puppet::params {
  class { 'puppet::common':
    user_id  => $user_id,
    group_id => $group_id,
  }

  if $::kernel == "Linux" {
    file { $puppet_defaults:
      mode   => '0644',
      owner  => 'root',
      group  => 'root',
      source => "puppet:///modules/puppet/${puppet_defaults}",
    }
  }

  if !defined(Package[$puppet_agent_name]) {
    package { $puppet_agent_name:
      ensure   => $version,
      provider => $package_provider,
      before   => File[$confdir],
    }

  }

  case $puppet_run_style {
    'service' : {
      if $package_provider == 'gem' {
        $service_notify = Exec['puppet_agent_start']

        exec { 'puppet_agent_start':
          command   => '/usr/bin/nohup puppet agent &',
          refresh   => '/usr/bin/pkill puppet && /usr/bin/nohup puppet agent &',
          unless    => "/bin/ps -ef | grep -v grep | /bin/grep 'puppet agent'",
          require   => File[$puppet_conf],
          subscribe => Package[$puppet_agent_name],
        }
      } else {
        $service_notify = Service[$puppet_agent_service]

        service { $puppet_agent_service:
          ensure     => running,
          enable     => true,
          hasstatus  => true,
          hasrestart => true,
          require    => File[$puppet_conf],
          subscribe  => Package[$puppet_agent_name],
        }
      }

      Concat <| title == $puppet_conf |> {
        require => Package['puppet'],
        notify  +> $puppet::agent::service_notify,
      }

    }
    'cron'    : {
      # ensure that puppet is running and will start up on boot
      service { $puppet_agent_service:
        ensure     => 'stopped',
        enable     => false,
        hasrestart => true,
        hasstatus  => true,
        require    => Package[$puppet_agent_name],
      }

      # Run puppet as a cron - this saves memory and avoids the whole problem
      # where puppet locks up for no reason. Also spreads out the run intervals
      # more uniformly.
      $time1 = fqdn_rand($puppet_run_interval)
      $time2 = fqdn_rand($puppet_run_interval) + 30

      cron { 'puppet-client':
        command => '/usr/sbin/puppet agent --no-daemonize --onetime --logdest syslog > /dev/null 2>&1',
        user    => 'root',
        # run twice an hour, at a random minute in order not to collectively stress the puppetmaster
        hour    => '*',
        minute  => [$time1, $time2],
      }

      Concat <| title == $puppet_conf |> {
        require => Package['puppet'],
      }

    }
    default   : {
      err("Unsupported puppet run style in Class[\'puppet::agent\']")
    }
  }

  concat::fragment { 'puppet.conf-agent':
    order   => '00',
    target  => $puppet_conf,
    content => template("puppet/puppet.conf-agent.erb"),
  }
}
