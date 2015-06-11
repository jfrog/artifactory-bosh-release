#Artifactory BOSH release
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
ruby-install 2.1.2
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

- To use this release you must provide the Artifactory license string
in an environment variable called ARTIFACTORY_LICENSE.

To deploy into a development environment:

```
export  ARTIFACTORY_DB_HOST=10.60.3.55
export  ARTIFACTORY_DB_PORT=3306
export  ARTIFACTORY_DB_NAME=artdb_cf
export  ARTIFACTORY_DB_USERNAME=artifactory
export  ARTIFACTORY_DB_PASSWORD=password
export  ARTIFACTORY_LICENSE=$(cat assets/artifactory.lic)
export  NATS_USERNAME=nats
export  NATS_PASSWORD=password
export  NATS_HOST=10.60.3.2
export  NATS_PORT=4222
export  CF_DOMAIN=cf.jfrog.local

bosh -n create release --force && bosh upload release && bosh deploy
```

## Running the tests

Note that the tests expect artifactory to have been deployed to your BOSH
environment. You must specify two license keys with different valid through dates
to use during testing.

### Via Vagrant

```
export  BOSH_TARGET=192.168.50.4
export  BOSH_DIRECTOR_SSH_USERNAME=vagrant
export  BOSH_DIRECTOR_SSH_PASSWORD=vagrant
export  BOSH_MANIFEST=manifests/artifactory-lite.yml
export  TEST_LICENSE_1=$(cat assets/artifactory.lic)
export  TEST_LICENSE_2=$(cat assets/artifactory-expired.lic)
export  ARTIFACTORY_DB_HOST=10.60.3.55
export  ARTIFACTORY_DB_PORT=3306
export  ARTIFACTORY_DB_NAME=artdb_cf
export  ARTIFACTORY_DB_USERNAME=artifactory
export  ARTIFACTORY_DB_PASSWORD=password
export  NATS_USERNAME=nats
export  NATS_PASSWORD=password
export  NATS_HOST=10.60.3.2
export  NATS_PORT=4222
bundle exec rspec --format d

```

### Via vSphere

```
export BOSH_TARGET=10.60.4.6
export  BOSH_DIRECTOR_SSH_USERNAME=vcap
export  BOSH_DIRECTOR_SSH_PASSWORD=c1oudc0w
export  BOSH_MANIFEST=manifests/artifactory-vsphere.yml
export  TEST_LICENSE_1=$(cat assets/artifactory.lic)
export  TEST_LICENSE_2=$(cat assets/artifactory-expired.lic)
export  ARTIFACTORY_DB_HOST=10.60.3.55
export  ARTIFACTORY_DB_PORT=3306
export  ARTIFACTORY_DB_NAME=artdb_cf
export  ARTIFACTORY_DB_USERNAME=artifactory
export  ARTIFACTORY_DB_PASSWORD=password
export  NATS_USERNAME=nats
export  NATS_PASSWORD=password
export  NATS_HOST=10.60.3.2
export  NATS_PORT=4222
export  CF_DOMAIN=cf.jfrog.local
bundle exec rspec --format d

```
