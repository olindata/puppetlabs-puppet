require 'spec_helper_acceptance'

describe 'agent tests:' do
    context 'default parameters puppet::agent' do
        it 'should work with no errors' do
            pp = <<-EOS
                class { 'puppet::agent': }
            EOS
            # Run it twice and test for idempotency
            apply_manifest(pp, :catch_failures => true)
            apply_manifest(pp, :catch_changes => true)
        end

        describe package('puppet') do
            it { should be_installed }
        end

        describe service('puppet') do
            it { should be_running }
            it { should be_enabled }
        end
    end

    context 'agent run from cron' do
        it 'should work with no errors' do
            pp = <<-EOS
                class { 'puppet::agent':
                    puppet_run_style => 'cron',
                }
            EOS

            # Run it twice and test for idempotency
            apply_manifest(pp, :catch_failures => true)
            apply_manifest(pp, :catch_changes => true)
        end

        describe package('puppet') do
            it { should be_installed }
        end

        describe service('puppet') do
            # Service detection on Debian seems to be broken,
            # at least for the puppet service
            it { should_not be_running }
            it { should_not be_enabled }
        end

        describe cron do
            # Note: This only has four *'s since the minute part is randomized
            # by the agent module.
            it { should have_entry "* * * * \/usr\/bin\/puppet agent --no-daemonize --onetime --logdest syslog > \/dev\/null 2>&1" }
        end
    end

    context 'agent run style manual' do
        it 'should work with no errors' do
            pp = <<-EOS
                class { 'puppet::agent':
                    puppet_run_style => 'manual',
                }
            EOS

            # Run it twice and test for idempotency
            apply_manifest(pp, :catch_failures => true)
            apply_manifest(pp, :catch_changes => true)
        end

        describe package('puppet') do
            it { should be_installed }
        end
    end

    context 'agent with external scheduler' do
        it 'should run without errors' do
            pp = <<-EOS
                class { 'puppet::agent':
                    puppet_run_style => external,
                }
            EOS
            # Run it twice and test for idempotency
            apply_manifest(pp, :catch_failures => true)
            apply_manifest(pp, :catch_changes => true)
        end

        describe package('puppet') do
            it { should be_installed }
        end

        describe service('puppet') do
          it { should_not be_running }
          it { should_not be_enabled }
        end
    end

    context 'agent with external scheduler' do
        it 'should run without errors' do
            pp = <<-EOS
                class { 'puppet::agent':
                    puppet_run_style => external,
                    templatedir => undef,
                }
            EOS
            # Run it twice and test for idempotency
            apply_manifest(pp, :catch_failures => true)
            apply_manifest(pp, :catch_changes => true)
        end

        describe package('puppet') do
            it { should be_installed }
        end

        describe service('puppet') do
          it { should_not be_running }
          it { should_not be_enabled }
        end
    end
end
