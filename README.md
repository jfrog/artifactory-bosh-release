#Artifactory BOSH release
##KNOWN ISSUES
After long consideration of pros and cons, the monit script will go for several minutes before attempting a restart.  This may be possible to fix in recent versions of bosh, let us know if you are using this and ask for it.

## To setup your workstation:
-To start this project from 0:

###Prerequisites
####Setting up Ruby
Ruby  (Need version 2.1.2).  Suggest you configure it to point to your artifactory server, if you have one.
Macs come with a different version of ruby.  May want to consider chruby to solve this problem.
```
brew install chruby
```
this will give you some instructions on some things you need to add to your profile/bashrc. Follow these instructions.  Then:
```
brew install ruby-install
ruby-install ruby 2.1.2
```
Now make sure you close the shell and start a new one.  OTHERWISE chruby WILL NOT WORK
####Other Prerequisites
mysql (for testing): this is a prerequisite of the ruby mysql gem.

###Setting up ruby and bosh
Depending on your configuration, the following command may require sudo.

- Clone this repository: If desired, modify the sources line in Gemfile to point at an Artifactory
- Now to install the necessary gems, from the root of this git:

```
gem install bundler
bundle install
```

## Configuration

- Setup a mysql database for use by Artifactory

```
CREATE USER artifactory IDENTIFIED BY 'password';
CREATE DATABASE artdb_cf CHARACTER SET utf8;
GRANT ALL on artdb_cf.* TO 'artifactory'@'%' IDENTIFIED BY 'password';
FLUSH PRIVILEGES;
```

- Add submodule route-registrar:
   Run following command in root directory of Project.
```
git submodule init
git submodule update
```


- To use this release you must provide the Artifactory license string
in an environment variable called ARTIFACTORY_LICENSE.

To deploy into a development environment:

```
export  ARTIFACTORY_DB_HOST=10.60.3.55
export  ARTIFACTORY_DB_PORT=3306
export  ARTIFACTORY_DB_NAME=artdb_cf
export  ARTIFACTORY_DB_USERNAME=artifactory
export  ARTIFACTORY_DB_PASSWORD=password
export ARTIFACTORY_LICENSE=$(cat assets/artifactory-H1.lic)
export ARTIFACTORY1_LICENSE=$(cat assets/artifactory-H2.lic)
export ARTIFACTORY2_LICENSE=$(cat assets/artifactory-H3.lic)
export  NATS_USERNAME=nats
export  NATS_PASSWORD=password
export  NATS_HOST=10.60.3.2
export  NATS_PORT=4222
export  CF_DOMAIN=cf.jfrog.local

export  BINARYSTORE_PROVIDER=For GCP use "google-storage", for aws-s3 use "s3", for nfs use "file-system"
export  BINARYSTORE_BUCKETNAME=bucketname
export  BINARYSTORE_ENDPOINT=endpoint
export  BINARYSTORE_REGION=region
export  BINARYSTORE_IDENTITY=identity
export  BINARYSTORE_CREDENTIAL=credential
export  BINARY_NFS_MOUNTPOINT=your nfs point location

bosh -n create release --force --with-tarball && bosh upload release
```

Set Manifest before deploy:

```
bosh deployment manifests/{{your_target}}.yml
bosh deploy
```

## Running the tests

Note that the tests expect artifactory to have been deployed to your BOSH
environment. You must specify two license keys with different valid through dates
to use during testing.

### Via vSphere

```
export ARTIFACTORY_LICENSE=$(cat assets/bosh-art-H1.lic)
export ARTIFACTORY1_LICENSE=$(cat assets/bosh-art-H2.lic)
export ARTIFACTORY2_LICENSE=$(cat assets/bosh-art-H3.lic)
export TEST_LICENSE=$(cat assets/bosh-art-H1.lic)
export TEST_LICENSE_1=$(cat assets/bosh-art-H2.lic)
export  TEST_LICENSE_2=$(cat assets/bosh-art-T1.lic)
export  TEST_LICENSE_3=$(cat assets/bosh-art-T1.lic)
export  TEST_LICENSE_4=$(cat assets/bosh-art-H3.lic)
export  EXPECTED_ARTIFACTORY_VERSION=4.15.0
export  BOSH_TARGET=10.60.7.6
export  BOSH_DIRECTOR_SSH_USERNAME=vcap
export  BOSH_DIRECTOR_SSH_PASSWORD=c1oudc0w
export  BOSH_MANIFEST=manifests/artifactory-ha-vsphere.yml
export  ARTIFACTORY_DB_HOST=10.60.3.55
export  ARTIFACTORY_DB_PORT=3306
export  ARTIFACTORY_DB_NAME=artdb_bosh
export  ARTIFACTORY_DB_USERNAME=artifactory
export  ARTIFACTORY_DB_PASSWORD=password
export  NATS_USERNAME=nats
export  NATS_HOST=10.60.3.2
export  NATS_PORT=4222
export  CF_DOMAIN=cf.jfrog.local
export  BINARYSTORE_PROVIDER=s3
export  BINARYSTORE_BUCKETNAME=artifactory-bosh-test-01
export  BINARYSTORE_ENDPOINT=http://s3.amazonaws.com
export  BINARYSTORE_REGION=us-west-2
export  NATS_PASSWORD=password
export  BINARYSTORE_IDENTITY=identity
export  BINARYSTORE_CREDENTIAL=credential
export  BINARYSTORE_IDENTITY_GC=identity
export  BINARYSTORE_CREDENTIAL_GC=credential
export  BINARYSTORE_IDENTITY_S3=identity
export  BINARYSTORE_CREDENTIAL_S3=credential
export  BINARY_NFS_MOUNTPOINT=your nfs point location
bundle exec rspec --format d

```
