require 'spec_helper'
require 'net/ssh/gateway'
require 'rest-client'
require 'yaml'

describe 'Standalone Artifactory' do
  it 'should verify that deployed artifactory is running and version is correct' do
    bundle_exec_bosh "target #{bosh_target}"
    bundle_exec_bosh "deployment #{bosh_manifest}"
    bundle_exec_bosh "login #{bosh_username} #{bosh_password}"

    gateway = Net::SSH::Gateway.new(bosh_target, bosh_director_ssh_username,
                                    :password => bosh_director_ssh_password)

    standalone_node_ip = get_standalone_node_ip_from bosh_manifest

    gateway.open(standalone_node_ip, artifactory_port) do |port|
      response = RestClient.get artifactory_version_url port
      expect(JSON.parse(response)['version']).to eq(expected_artifactory_version)
    end
  end
end

def bundle_exec_bosh command
  output = `bundle exec bosh -n #{command}`
  expect($?.to_i).to eq(0), output
end

def get_standalone_node_ip_from bosh_manifest
 YAML.load_file(bosh_manifest)['jobs'].
   find{|job_hash| job_hash['name'] == 'standalone'}['networks'].
   first['static_ips'].first
end

def bosh_target
  ENV['BOSH_TARGET'] || '192.168.50.4'
end

def bosh_username
  ENV['BOSH_USERNAME'] || 'admin'
end

def bosh_password
  ENV['BOSH_PASSWORD'] || 'admin'
end

def bosh_manifest
  ENV['BOSH_MANIFEST'] || 'manifests/artifactory-lite.yml'
end

def expected_artifactory_version
  ENV['EXPECTED_ARTIFACTORY_VERSION'] || '3.7.0'
end

def artifactory_port
  ENV['ARTIFACTORY_PORT'] || 8081
end

def artifactory_version_url port
 "http://localhost:#{port}/artifactory/api/system/version"
end

def bosh_director_ssh_username
  ENV['BOSH_DIRECTOR_SSH_USERNAME'] || 'vagrant'
end

def bosh_director_ssh_password
  ENV['BOSH_DIRECTOR_SSH_PASSWORD'] || 'vagrant'
end
