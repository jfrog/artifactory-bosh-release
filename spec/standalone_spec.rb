require 'spec_helper'
require 'net/ssh/gateway'
require 'rest-client'
require 'yaml'

describe 'Standalone Artifactory' do

  before(:all) do
    @gateway = Net::SSH::Gateway.new(bosh_target, bosh_director_ssh_username,
      :password => bosh_director_ssh_password)
    @standalone_node_ip = get_standalone_node_ip_from bosh_manifest
    bundle_exec_bosh "target #{bosh_target}"
    bundle_exec_bosh "deployment #{bosh_manifest}"
    bundle_exec_bosh "login #{bosh_username} #{bosh_password}"
    #TODO: is hardcoding the license here really the right answer?
    ENV["ARTIFACTORY_LICENSE"] = ENV["TEST_LICENSE_1"]
    bosh_deploy_and_wait_for_artifactory
  end
  
  describe 'Initial Checks' do
    it 'should verify that deployed artifactory is running and version is correct' do
      exec_on_gateway do | port |
        response = RestClient.get artifactory_version_url port
        expect(JSON.parse(response)['version']).to eq(expected_artifactory_version)
      end
    end
  end


  describe 'licensing' do
    it 'should have a license present' do
      exec_on_gateway do | port |
        response = RestClient.get artifactory_license_url port
        expect(JSON.parse(response)['type']).to eq('Trial')
        $original_expiry_date = JSON.parse(response)['validThrough']
      end
    end

    context 'when a license is not present' do  
      it 'is still accessible' do
        ENV["ARTIFACTORY_LICENSE"] = ""
        bosh_deploy_and_wait_for_artifactory        
        exec_on_gateway do | port |
          response = RestClient.get artifactory_version_url port
          expect(JSON.parse(response)['version']).to eq(expected_artifactory_version)
        end
      end
    end



    context 'when license is changed' do


      #reset the BOSH deployment to the original
      after(:all) do
        puts "Resetting to original license from deployment"
        ENV["ARTIFACTORY_LICENSE"] = ENV["TEST_LICENSE_1"]
        bosh_deploy_and_wait_for_artifactory
      end

      it 'updates the license' do
       ENV["ARTIFACTORY_LICENSE"] = ENV["TEST_LICENSE_2"]
       puts "Deploying Lic 2"
       bosh_deploy_and_wait_for_artifactory 
       exec_on_gateway do | port |
        response = RestClient.get artifactory_license_url port
        expect(JSON.parse(response)['validThrough']).to_not eq(@original_expiry_date)
      end
    end

  end
end


def bosh_deploy_and_wait_for_artifactory
  bundle_exec_bosh "deploy"
  wait_for_artifactory_available
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

def exec_on_gateway
  @gateway.open(@standalone_node_ip, artifactory_port) do |port|
    yield port
  end
end

def wait_for_artifactory_available
  exec_on_gateway do | port |
    begin
      RestClient.get artifactory_status_api port
    rescue RestClient::ServiceUnavailable
      puts "still waiting for artifactory to become available, sleeping for 5secs"
      sleep(5)
      retry
    rescue RestClient::Forbidden
      puts "license maybe expired"
    end
    puts "artifactory available"
  end
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

def artifactory_admin_user
  "admin"
end

def artifactory_admin_password
  "password"
end

def artifactory_port
  ENV['ARTIFACTORY_PORT'] || 8081
end

def artifactory_api port
  "http://localhost:#{port}/artifactory/api"
end

def artifactory_authenticated_api port
  "http://#{artifactory_admin_user}:#{artifactory_admin_password}@localhost:#{port}/artifactory/api"
end

def artifactory_status_api port
 "#{artifactory_authenticated_api(port)}/system/ping"
end

def artifactory_version_url port
 "#{artifactory_api(port)}/system/version"
end

def artifactory_license_url port
 "#{artifactory_authenticated_api(port)}/system/license"
end

def bosh_director_ssh_username
  ENV['BOSH_DIRECTOR_SSH_USERNAME'] || 'vagrant'
end

def bosh_director_ssh_password
  ENV['BOSH_DIRECTOR_SSH_PASSWORD'] || 'vagrant'
end
