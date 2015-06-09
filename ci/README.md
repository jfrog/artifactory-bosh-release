#CI Pipeline for Concourse

Note: Current pipeline implementation means you SHOULD NOT push while the pipleline
is running.

TODO: Branch strategy to eliminate this issue.

## Concourse Setup

### Concourse Installation

For a simple Concourse environment via Vagrant follow the docs [here](http://concourse.ci/deploying-with-vagrant.html).
Use `fly save-target <URL of concourse>`

### Pipeline configuration

To configure the concourse pipeline run the following command from the root project directory.
You must specify two license keys with different valid through dates to use during testing (provide the full license string without whitespace or line breaks in the environment variable)

```
fly c -c ci/pipelines/pipeline.yml
 --vars-from ci/credentials.yml
 --vars-from ci/bosh_credentials.yml
 --vars-from ci/database_credentials.yml
 --vars-from ci/cf_credentials.yml
 --var test_license_1=$(cat assets/artifactory.lic)
 --var test_license_2=$(cat assets/artifactory-expired.lic)
 --var artifactory_manifest=manifests/artifactory-vsphere.yml
 --var artifactory_license==$(cat assets/artifactory.lic)
```

### Fly CLI Setup

Goto [Concourse](http://192.168.100.4:8080/pipelines/main) and download the
CLI for your system from the bottom right hand corner.

## Docker Images

In the concourse pipeline we use an cf-artifactory-ci image
, this can be built from the dockerfile in the docker dir.

```
cd docker
docker build .
docker tag *imgid* cloudfoundry/cf-artifactory-ci:latest
docker push cloudfoundry/cf-artifactory-ci:latest
```
