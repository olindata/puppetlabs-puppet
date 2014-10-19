require 'spec_helper_acceptance'

describe 'master tests:' do
    context 'without puppetdb' do
        it 'puppet::master class should work with no errors' do
            pp = <<-EOS
                class { 'puppet::master':}
            EOS

            # Run it twice and test for idempotency
            apply_manifest(pp, :catch_failures => true)
            #TODO fix me, should apply cleanly on one run
            #apply_manifest(pp, :catch_changes => true)
        end
    end

    context 'with external puppetdb' do
        it 'puppet::master class should work with no errors' do
            pp = <<-EOS
                class { 'puppet::master':
                    storeconfigs               => true,
                    storeconfigs_dbserver      => 'puppetdb.foo.local',
                    puppetdb_strict_validation => false,
                }
            EOS

            # Run it twice and test for idempotency
            apply_manifest(pp, :catch_failures => true)
            #TODO fix me, should apply cleanly on one run
            #apply_manifest(pp, :catch_changes => true)
        end
    end

    # This test has to be after the non-puppetdb tests
    context 'with puppetdb' do
        it 'puppet::master class should work with no errors' do
            pp = <<-EOS
                class { 'puppetdb': }
                class { 'puppet::master':
                    storeconfigs               => true,
                }
            EOS

            # Run it twice and test for idempotency
            apply_manifest(pp, :catch_failures => true)
            #TODO fix me, should apply cleanly on one run
            #apply_manifest(pp, :catch_changes => true)
        end
    end
end
