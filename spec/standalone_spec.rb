require 'spec_helper'

describe 'Standalone Artifactory' do
  it 'should work' do
    bundle_exec_bosh 'target lite'
    bundle_exec_bosh 'deployment manifests/artifactory-lite.yml'
    bundle_exec_bosh 'login admin admin'
    bundle_exec_bosh 'recreate standalone 0'
  end
end

def bundle_exec_bosh command
  output = `bundle exec bosh -n #{command}`
  expect($?.to_i).to eq(0), output
end
