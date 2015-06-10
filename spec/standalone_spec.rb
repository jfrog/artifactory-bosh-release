require 'spec_helper'
require 'net/ssh/gateway'
require 'rest-client'
require 'yaml'
require 'json'
require 'securerandom'
require 'mysql'
require 'digest'

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

  after(:all) do
    puts 'verify that route is still available after the tests have ran'
    response = RestClient.get artifactory_route_version_url
    expect(JSON.parse(response)['version']).to eq(expected_artifactory_version)
  end

  describe 'Initial Checks' do
    it 'should verify that deployed artifactory is running and version is correct' do
      exec_on_gateway do | port |
        response = RestClient.get artifactory_version_url port
        expect(JSON.parse(response)['version']).to eq(expected_artifactory_version)
      end
    end

    it 'should verify that artifactory is accessible via the route' do
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

  describe 'peristence' do
    describe "database connection" do
      context "adding a new user" do
        let(:random_user) { SecureRandom.hex }

        before do
          exec_on_gateway do | port |
            response = RestClient.get artifactory_users_url(port: port)
            user = JSON.parse(response).find do | user |
              user.fetch("name") == random_user
            end
            expect(user).to be_nil

            new_user = JSON.generate(:name => random_user, :password => "pass", :email => "#{random_user}@test.com")
            RestClient.put artifactory_users_url(user: random_user, port: port), new_user,:content_type => 'application/json'
          end
        end

        after do
          exec_on_gateway do | port |
            RestClient.delete artifactory_users_url(user: random_user, port: port)
          end
        end

        it 'should be present in the mysql database' do
          con = Mysql.connect(ENV["ARTIFACTORY_DB_HOST"], ENV["ARTIFACTORY_DB_USERNAME"],
                              ENV["ARTIFACTORY_DB_PASSWORD"], ENV["ARTIFACTORY_DB_NAME"],
                              ENV["ARTIFACTORY_DB_PORT"].to_i)
          rs = con.query "SELECT count(*) FROM artdb_cf.users WHERE username = '#{random_user}'"
          con.close
          expect(rs.fetch_hash['count(*)'].to_i).to eq(1)
        end
      end
    end

    describe 'recreating vms' do

      before(:all) do
        @filename_artifact = SecureRandom.hex
        @filepath_backup = "#{artifactory_package_path}/backup/#{SecureRandom.hex}"
        @filepath_data =  "#{artifactory_package_path}/data/#{SecureRandom.hex}"
        @filepath_etc = "#{artifactory_package_path}/etc/#{SecureRandom.hex}"
        @file_sha1 = ""

        #upload an artifact
        exec_on_gateway do | port |
          response = RestClient.put artifactory_artifact_url(filename: @filename_artifact, port: port), File.read('README.md'), :content_type => 'text'
          @file_sha1 = JSON.parse(response)["checksums"]["sha1"]
          puts "uploaded file #{@filename_artifact} to artifactory with sha1 #{@file_sha1}"
        end
        #create a file in backup / data / etc
        exec_on_node(@standalone_node_ip, "touch #{@filepath_backup}", :root => true )
        exec_on_node(@standalone_node_ip, "touch #{@filepath_data}", :root => true )
        exec_on_node(@standalone_node_ip, "touch #{@filepath_etc}", :root => true )
        #delete and recreate vms but not disks
        puts "stopping artifactory"
        bundle_exec_bosh "stop standalone --soft"
        puts "recreating nfs_server"
        bundle_exec_bosh "recreate nfs_server"
        puts "recreating standalone"
        bundle_exec_bosh "recreate standalone"

        wait_for_artifactory_available
      end

      after(:all) do
        #delete the artifact
        exec_on_gateway do | port |
          RestClient.delete artifactory_artifact_url(filename: @filename_artifact, port: port)
        end
        #delte the file in backup / data / etc
        exec_on_node(@standalone_node_ip, "rm #{@filepath_backup}", :root => true )
        exec_on_node(@standalone_node_ip, "rm #{@filepath_data}", :root => true )
        exec_on_node(@standalone_node_ip, "rm #{@filepath_etc}", :root => true )
      end

      context 'when both the standalone & nfs_server are recreated by an operator' do
        it 'still has backup data' do
          result = exec_on_node(@standalone_node_ip, "ls #{@filepath_backup}")
          expect(result).to eq("#{@filepath_backup}\n")
        end

        it 'still has etc data' do
          result = exec_on_node(@standalone_node_ip, "ls #{@filepath_etc}")
          expect(result).to eq("#{@filepath_etc}\n")
        end

        it 'still has data dir data' do
          result = exec_on_node(@standalone_node_ip, "ls #{@filepath_data}")
          expect(result).to eq("#{@filepath_data}\n")
        end

        it 'still has the artifacts' do
          #verfiy the artifact can be downloaded again
          exec_on_gateway do | port |
            response = RestClient.get artifactory_artifact_url(filename: @filename_artifact, port: port)
            expect(Digest::SHA1.hexdigest(response)).to eq(@file_sha1)
          end
        end
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

def artifactory_users_url(user: "", port:)
  if user == ""
    "#{artifactory_authenticated_api(port)}/security/users"
  else
    "#{artifactory_authenticated_api(port)}/security/users/#{user}"
  end
end

def artifactory_artifact_url(filename:,  port:)
  "http://#{artifactory_admin_user}:#{artifactory_admin_password}@localhost:#{port}/artifactory/libs-release-local/#{filename}"
end

def artifactory_route_version_url
  "http://bosh-artifactory.#{cf_domain}/artifactory/api/system/version"
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

def artifactory_package_path
  "/var/vcap/packages/artifactory"
end

def artifactory_package_logs
  artifactory_package_path+"/logs/"
end

def artifactory_sys_logs
  "/var/vcap/sys/log/artifactory/"
end
