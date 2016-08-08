require 'spec_helper'
require 'net/ssh/gateway'
require 'rest-client'
require 'yaml'
require 'json'
require 'securerandom'
require 'mysql'
require 'digest'

describe 'HA Artifactory' do
  before(:all) do
    @gateway = Net::SSH::Gateway.new(bosh_target, bosh_director_ssh_username,
      :password => bosh_director_ssh_password)
    @load_balancer_ip = get_load_balancer_ip_from bosh_manifest
    @standalone_node_ip = get_first_node_ip_from bosh_manifest
    bundle_exec_bosh "target #{bosh_target}"
    bundle_exec_bosh "deployment #{bosh_manifest}"
    bundle_exec_bosh "login #{bosh_username} #{bosh_password}"
    #TODO: is hardcoding the license here really the right answer?
    ENV["ARTIFACTORY1_LICENSE"] = ENV["TEST_LICENSE_1"]
    ENV["ARTIFACTORY_LICENSE"] = ENV["TEST_LICENSE"]
    bosh_deploy_and_wait_for_artifactory
  end

  describe 'Initial Checks' do
    it 'should verify that deployed artifactory is running, version is correct and HA addon is available' do
      response = RestClient.get "http://admin:password@" + @load_balancer_ip + "/artifactory/api/system/version"
      expect(JSON.parse(response)['version']).to eq(expected_artifactory_version)
      expect(JSON.parse(response)['addons'].include? 'ha').to eq(true)
    end

    it 'should verify that artifactory is accessible via the route' do
      wait_for_artifactory_route_available
      response = RestClient.get artifactory_route_version_url
      expect(JSON.parse(response)['version']).to eq(expected_artifactory_version)
    end

    describe 'artifactory logs dir' do
      it 'should have artifactory log' do
        log_path = artifactory_package_logs+'artifactory.log'
        result = exec_on_node(@standalone_node_ip, "ls #{log_path}")
        expect(result).to eq("#{log_path}\n")
      end

      it 'should have access log' do
        log_path = artifactory_package_logs+'access.log'
        result = exec_on_node(@standalone_node_ip, "ls #{log_path}")
        expect(result).to eq("#{log_path}\n")
      end

      it 'should have request log' do
        log_path = artifactory_package_logs+'request.log'
        result = exec_on_node(@standalone_node_ip, "ls #{log_path}")
        expect(result).to eq("#{log_path}\n")
      end

      it 'should have import.export log' do
        log_path = artifactory_package_logs+'import.export.log'
        result = exec_on_node(@standalone_node_ip, "ls #{log_path}")
        expect(result).to eq("#{log_path}\n")
      end
    end
  end



  describe 'licensing' do
    it 'should have a license present' do
        response = RestClient.get artifactory_license_url artifactory_port
	expect(JSON.parse(response)['type']).to eq('High Availability')
        parsed_response = JSON.parse(response)['validThrough']
        $original_expiry_date = parsed_response
        puts "Original Expiry date: #{$original_expiry_date}"
    end

    context 'when license is changed' do

      it 'updates the license' do
        ENV["ARTIFACTORY_LICENSE"] = ENV["TEST_LICENSE_2"]
        ENV["ARTIFACTORY1_LICENSE"] = ENV["TEST_LICENSE_3"]
        puts "Deploying Lic 2:  If this test fails, check expiration date of license 2"
        bosh_deploy_and_wait_for_artifactory
        response = RestClient.get artifactory_license_url artifactory_port
        parsed_response = JSON.parse(response)['validThrough']
        puts "Expiry Date: #{parsed_response}"
        expect(parsed_response).to_not eq($original_expiry_date)
      end

      it 'resets to the original license' do
        puts 'Resetting to original license from deployment'
        ENV["ARTIFACTORY1_LICENSE"] = ENV["TEST_LICENSE_1"]
        ENV["ARTIFACTORY_LICENSE"] = ENV["TEST_LICENSE"]
        bosh_deploy_and_wait_for_artifactory
        response = RestClient.get artifactory_license_url artifactory_port
        parsed_response = JSON.parse(response)['validThrough']
        puts "Expiry Date: #{parsed_response}"
        expect(parsed_response).to eq($original_expiry_date)
      end
    end
  end

  describe 'Scaling' do
    context 'Scale to 1 and verify artifactory still accessible' do
      it 'Deploys down to 1 node and verify artifactory still accessible' do
        ENV["ARTIFACTORY1_LICENSE"] = ENV["TEST_LICENSE_1"]
        bundle_exec_bosh "deployment #{bosh_manifest_source}1.yml"
        bosh_deploy_and_wait_for_artifactory
        response = RestClient.get artifactory_route_version_url
        expect(JSON.parse(response)['version']).to eq(expected_artifactory_version)
      end
      it 'should verify via clusterdump number of active nodes'
    end
    context 'Scale to 3' do
      it 'Deploys 3 nodes and verify artifactory still accessible' do
        ENV["ARTIFACTORY1_LICENSE"] = ENV["TEST_LICENSE_1"]
        ENV["ARTIFACTORY_LICENSE"] = ENV["TEST_LICENSE"]
        ENV["ARTIFACTORY2_LICENSE"] = ENV["TEST_LICENSE_4"]
        bundle_exec_bosh "deployment #{bosh_manifest_source}3.yml"
        bosh_deploy_and_wait_for_artifactory
        wait_for_artifactory_route_available
        response = RestClient.get artifactory_route_version_url
        expect(JSON.parse(response)['version']).to eq(expected_artifactory_version)
      end
      it 'should verify via clusterdump number of active nodes'
    end
    context 'Scale to 3 artifactory and 2 nginx' do
      it 'Deploys 3 nodes w/2 nginx and verify artifactory still accessible' do
        ENV["ARTIFACTORY1_LICENSE"] = ENV["TEST_LICENSE_1"]
        ENV["ARTIFACTORY_LICENSE"] = ENV["TEST_LICENSE"]
        ENV["ARTIFACTORY2_LICENSE"] = ENV["TEST_LICENSE_4"]
        bundle_exec_bosh "deployment #{bosh_manifest_source}3-2.yml"
        bosh_deploy_and_wait_for_artifactory
        wait_for_artifactory_route_available
        response = RestClient.get artifactory_route_version_url
        expect(JSON.parse(response)['version']).to eq(expected_artifactory_version)
      end
      it 'should verify via clusterdump number of active nodes'
      it 'should verify that load balancing is functioning' do
        pending("nginx check")
        raise 'nginx has a local ip dependency for docker'
      end
    end
  end

  describe 'binary store check' do
    context 'GCP' do
      it 'deploys and is accessible' do
        ENV["BINARYSTORE_IDENTITY"] = ENV["BINARYSTORE_IDENTITY_GC"]
        ENV["BINARYSTORE_CREDENTIAL"] = ENV["BINARYSTORE_CREDENTIAL_GC"]
        bundle_exec_bosh "deployment #{bosh_manifest_source}-gc.yml"
        bosh_deploy_and_wait_for_artifactory
        wait_for_artifactory_route_available
        response = RestClient.get artifactory_route_version_url
        expect(JSON.parse(response)['version']).to eq(expected_artifactory_version)
     end
      it 'can deploy and resolve artifacts'
      it 'verifies that objects actually went to blob'
    end
    context 'S3' do
      it 'deploys and is accessible'  do
        ENV["BINARYSTORE_IDENTITY"] = ENV["BINARYSTORE_IDENTITY_S3"]
        ENV["BINARYSTORE_CREDENTIAL"] = ENV["BINARYSTORE_CREDENTIAL_S3"]
        bundle_exec_bosh "deployment #{bosh_manifest_source}-s3.yml"
        bosh_deploy_and_wait_for_artifactory
        wait_for_artifactory_route_available
        response = RestClient.get artifactory_route_version_url
        expect(JSON.parse(response)['version']).to eq(expected_artifactory_version)
     end
      it 'can deploy and resolve artifacts'
      it 'verifies that objects actually went to blob'
    end
    context 'NFS' do
      it 'deploys and is accessible' do
        bundle_exec_bosh "deployment #{bosh_manifest_source}-nfs.yml"
        bosh_deploy_and_wait_for_artifactory
        wait_for_artifactory_route_available
        response = RestClient.get artifactory_route_version_url
        expect(JSON.parse(response)['version']).to eq(expected_artifactory_version)
      end
      it 'can deploy and resolve artifacts'
    end
  end

  describe 'final check' do
    context 'everything should be done now' do
      it 'confirms cluster has 3 nodes'
      it 'confirms that deploy/resolve works'
      it 'verify that route is still available after the tests have ran' do
        response = RestClient.get artifactory_route_version_url
        expect(JSON.parse(response)['version']).to eq(expected_artifactory_version)
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

def get_first_node_ip_from bosh_manifest
 YAML.load_file(bosh_manifest)['jobs'].
 find{|job_hash| job_hash['name'] == 'ha-artifactory'}['networks'].first['static_ips'].first
end

def get_load_balancer_ip_from bosh_manifest
 YAML.load_file(bosh_manifest)['jobs'].
 find{|job_hash| job_hash['name'] == 'nginx'}['properties']['artifactory_host']
end

def exec_on_gateway
  @gateway.open(@standalone_node_ip, artifactory_port) do |port|
    yield port
  end
end

def exec_on_node(node, cmd, options = {})
  user           = options.fetch(:user, 'vcap')
  password       = options.fetch(:password, 'c1oudc0w')
  run_as_root    = options.fetch(:root, false)
  discard_stderr = options.fetch(:discard_stderr, false)

  cmd = "echo -e \"#{password}\\n\" | sudo -S #{cmd}" if run_as_root
  cmd << ' 2>/dev/null' if discard_stderr

  @gateway.ssh(
    node,
    user,
    password: password,
    paranoid: false
  ) do |ssh|
    ssh.exec!(cmd)
  end
end

def wait_for_artifactory_available
  count = 0
  begin
    RestClient.get artifactory_status_api artifactory_port
  rescue RestClient::ServiceUnavailable
    puts "still waiting for artifactory to become available. count: #{count}; sleeping for 5secs"
    sleep(5)
    count = count + 1
    if count < 15 then
      retry
    else
      expect(count<15)
    end
  rescue RestClient::Forbidden
    puts "license may be expired"
  end
  puts "artifactory available"
end

def wait_for_artifactory_route_available
  count = 0
  begin
    RestClient.get artifactory_route_status_api
  rescue RestClient::ServiceUnavailable
    puts "still waiting for artifactory via route to become available. count: #{count}; sleeping for 5secs"
    sleep(5)
    count = count + 1
    if count < 15 then
      retry
    else
      expect(count<15)
    end
  rescue RestClient::Forbidden
    puts "license may be expired"
  end
  puts "artifactory via route available"
end

def bosh_target
  ENV['BOSH_TARGET'] || '192.168.50.4'
end

def cf_domain
  ENV['CF_DOMAIN']
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

def bosh_manifest_source
  bosh_manifest.chomp('.yml')
end

def expected_artifactory_version
  ENV['EXPECTED_ARTIFACTORY_VERSION'] || '4.11.0'
end

def artifactory_admin_user
  "admin"
end

def artifactory_admin_password
  "password"
end

def artifactory_port
  ENV['ARTIFACTORY_PORT'] || 80
end

def artifactory_api port
  "http://localhost:#{port}/artifactory/api"
end

def artifactory_authenticated_api port
  "http://#{artifactory_admin_user}:#{artifactory_admin_password}@localhost:#{port}/artifactory/api"
end

def artifactory_status_api port
 "http://#{artifactory_admin_user}:#{artifactory_admin_password}@"+ @load_balancer_ip +":#{port}/artifactory/api/system/ping"
end

def artifactory_users_url(user: "", port:)
  if user == ''
    "#{artifactory_authenticated_api(port)}/security/users"
  else
    "#{artifactory_authenticated_api(port)}/security/users/#{user}"
  end
end

def artifactory_artifact_url(filename:,  port:)
  "http://#{artifactory_admin_user}:#{artifactory_admin_password}@"+ @load_balancer_ip +":#{port}/artifactory/libs-release-local/#{filename}"
end

def artifactory_route_status_api
  "http://bosh-artifactory.#{cf_domain}/artifactory/api/system/ping"
end

def artifactory_route_version_url
  "http://#{artifactory_admin_user}:#{artifactory_admin_password}@bosh-artifactory.#{cf_domain}/artifactory/api/system/version"
end

def artifactory_version_url port
 "#{artifactory_api(port)}/system/version"
end

def artifactory_dummy_plugin port
  "#{artifactory_api(port)}/plugins/execute/dummyPlugin"
end

def artifactory_license_url port
 "http://#{artifactory_admin_user}:#{artifactory_admin_password}@"+ @load_balancer_ip +":#{port}/artifactory/api/system/license"
end

def bosh_director_ssh_username
  ENV['BOSH_DIRECTOR_SSH_USERNAME'] || 'vagrant'
end

def bosh_director_ssh_password
  ENV['BOSH_DIRECTOR_SSH_PASSWORD'] || 'vagrant'
end

def artifactory_package_path
  "/var/vcap/packages/artifactory"
end

def artifactory_package_logs
  artifactory_package_path+"/logs/"
end

def artifactory_sys_logs
  "/var/vcap/sys/log/artifactory/"
end
