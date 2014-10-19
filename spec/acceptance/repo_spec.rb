require 'spec_helper_acceptance'

describe 'repo tests:' do
    # Using puppet_apply as a helper
    it 'puppet::repo::puppetlabs class should work with no errors' do
        pp = <<-EOS
            class { 'puppet::repo::puppetlabs': }
        EOS

        # Run it twice and test for idempotency
        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes => true)
    end
end
