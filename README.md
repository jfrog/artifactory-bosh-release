#Artifactory BOSH release
## To setup your workstation:
-To start this project from 0:

###Prerequisites
Ruby  (pre-loaded on mac).  Suggest you configure it to point to your artifactory server, if you have one.
mysql (for testing).  A prerequisite of the ruby mysql gem

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
CREATE DATABASE artdb CHARACTER SET utf8;
GRANT ALL on artdb.* TO 'artifactory'@'%' IDENTIFIED BY 'password';
FLUSH PRIVILEGES;
```

- To use this release you must provide the Artifactory license string
in an environment variable called ARTIFACTORY_LICENSE (provide the full license string without whitespace or line breaks in the environment variable)

To deploy into a development environment:

```
export  ARTIFACTORY_DB_HOST=10.60.3.47
export  ARTIFACTORY_DB_PORT=3306
export  ARTIFACTORY_DB_NAME=artdb_cf
export  ARTIFACTORY_DB_USERNAME=artifactory
export  ARTIFACTORY_DB_PASSWORD=password
export  ARTIFACTORY_LICENSE=$(cat artifactory.lic)
bosh -n create release --force && bosh upload release && bosh deploy
```

## Running the tests

Note that the tests expect artifactory to have been deployed to your BOSH
environment. You must specify two license keys with different valid through dates
to use during testing (provide the full license string without whitespace or line breaks in the environment variable)

### Via Vagrant

```
export  BOSH_TARGET=192.168.50.4
export  BOSH_DIRECTOR_SSH_USERNAME=vagrant
export  BOSH_DIRECTOR_SSH_PASSWORD=vagrant
export  BOSH_MANIFEST=manifests/artifactory-lite.yml
export  TEST_LICENSE_1=$(cat assets/artifactory.lic)
export  TEST_LICENSE_2=$(cat assets/artifactory-expired.lic)
export  ARTIFACTORY_DB_HOST=10.60.3.47
export  ARTIFACTORY_DB_PORT=3306
export  ARTIFACTORY_DB_NAME=artdb_cf
export  ARTIFACTORY_DB_USERNAME=artifactory
export  ARTIFACTORY_DB_PASSWORD=password
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
export  ARTIFACTORY_DB_HOST=10.60.3.47
export  ARTIFACTORY_DB_PORT=3306
export  ARTIFACTORY_DB_NAME=artdb_cf
export  ARTIFACTORY_DB_USERNAME=artifactory
export  ARTIFACTORY_DB_PASSWORD=password
bundle exec rspec --format d

```
