require 'spec_helper'

describe 'puppet::masterenv', :type => :define do
  context "Create config environment" do
    let :title do
      'dev'
    end

    let :params do
      {
        :manifest        => '/etc/puppet/environments/dev.pp',
        :modulepath      => '/etc/puppet/environments/modules/',
        :puppet_conf     => '/etc/puppet/puppet.conf'
      }
    end
    it {
      should contain_ini_setting("masterenvmodule#{title}").with(
        :ensure  => 'present',
        :section => title,
        :setting => 'modulepath',
        :path    => params[:puppet_conf],
        :value   => params[:modulepath]
      )
      should contain_ini_setting("masterenvmanifest#{title}").with(
        :ensure  => 'present',
        :section => title,
        :setting => 'manifest',
        :path    => params[:puppet_conf],
        :value   => params[:manifest]
      )
    }
  end
  context "Create directory environment" do
    let :title do
      'dev'
    end

    let :params do
      {
        :manifest        => '/etc/puppet/environments/dev.pp',
        :modulepath      => '/etc/puppet/environments/modules/',
        :puppet_conf     => '/etc/puppet/puppet.conf',
        :environments    => 'directory',
        :environmentpath => '/etc/puppet/environments'
      }
    end
    it {
      should contain_ini_setting("masterenvmodule#{title}").with(
        :ensure  => 'present',
        :section => '',
        :setting => 'modulepath',
        :path    => '/etc/puppet/environments/dev/environment.conf',
        :value   => params[:modulepath]
      )
      should contain_ini_setting("masterenvmanifest#{title}").with(
        :ensure  => 'present',
        :section => '',
        :setting => 'manifest',
        :path    => '/etc/puppet/environments/dev/environment.conf',
        :value   => params[:manifest]
      )
     should contain_file("/etc/puppet/environments/dev").with(
       :ensure   => 'directory'
     )
    }
  end
end
