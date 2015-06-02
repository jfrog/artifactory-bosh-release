#Artifactory BOSH release
## To setup your workstation:
-To start this project from 0:

###Prerequisites
Ruby  (pre-loaded on mac).  Suggest you configure it to point to your artifactory server, if you have one.
###Setting up ruby and bosh
Depending on your configuration, the following command may require sudo.

- Clone this repository: If desired, modify the sources line in Gemfile to point at an Artifactory
- Now to install the necessary gems, from the root of this git:

```
gem install bundler
bundle install
```

## Configuration

- To use this release you must provide the Artifactory license string
in an environment variable called ARTIFACTORY_LICENSE (provide the full license string without whitespace or line breaks in the environment variable)

To deploy into a development environment:

```
bosh -n create release --force && bosh upload release
ARTIFACTORY_LICENSE=$(cat artifactory.lic) bosh deploy
```

## Running the tests

Note that the tests expect artifactory to have been deployed to your BOSH
environment. You must specify two license keys with different valid through dates
to use during testing (provide the full license string without whitespace or line breaks in the environment variable)

### Via Vagrant

```
export 	BOSH_TARGET=192.168.50.4
        BOSH_DIRECTOR_SSH_USERNAME=vagrant
        BOSH_DIRECTOR_SSH_PASSWORD=vagrant
        BOSH_MANIFEST=manifests/artifactory-lite.yml
        TEST_LICENSE_1=$(cat file1.lic)
        TEST_LICENSE_2=$(cat file1.lic)
bundle exec rspec --format d

```

### Via vSphere

```
export BOSH_TARGET=*vshpere bosh director IP*
	   BOSH_USERNAME=*vshpere bosh admin username*
	   BOSH_PASSWORD=*vshpere bosh admin password*
       BOSH_DIRECTOR_SSH_USERNAME=*vshpere bosh director ssh username*
       BOSH_DIRECTOR_SSH_PASSWORD=*vshpere bosh director ssh password*
       BOSH_MANIFEST=manifests/artifactory-vsphere.yml
       TEST_LICENSE_1=$(cat file1.lic)
       TEST_LICENSE_2=$(cat file1.lic)
bundle exec rspec --format d

```
