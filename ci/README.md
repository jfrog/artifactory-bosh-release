#CI Pipeline for Concourse

Note: Current pipeline implementation means you SHOULD NOT push while the pipleline
is running.

TODO: Branch strategy to eliminate this issue.

## Concourse Setup

### Concourse Installation

For a simple Concourse environment via Vagrant follow the docs [here](http://concourse.ci/deploying-with-vagrant.html).
Use `fly save-target <URL of concourse>`
for example:
```
fly login http://10.60.7.101:8080 vsphere7
```
### Pipeline configuration

To configure the concourse pipeline run the following command from the root project directory.
You must specify two pair of enterprise license keys with different valid through dates to use during testing (provide the full license string without whitespace or line breaks in the environment variable  . . . eg take out line breaks in license files below before using)

```
export ARTIFACTORY_LICENSE=$(cat assets/artifactory-H1.lic)
export ARTIFACTORY1_LICENSE=$(cat assets/artifactory-H2.lic)
export ARTIFACTORY2_LICENSE=$(cat assets/artifactory-H3.lic)
export  TEST_LICENSE_2=$(cat assets/artifactory-T2.lic)
export  TEST_LICENSE_3=$(cat assets/artifactory-T3.lic)
fly -t http://10.60.7.101:8080 sp -c ci/pipelines/pipeline.yml \
 --load-vars-from ci/credentials.yml \
 --load-vars-from ci/bosh_credentials.yml \
 --load-vars-from ci/release_database_credentials.yml \
 --load-vars-from ci/cf_credentials.yml \
 --load-vars-from ci/binarystore_credentials.yml \
 --var test_license_2="$(echo $TEST_LICENSE_2)" \
 --var test_license_3="$(echo $TEST_LICENSE_3)" \
 --var artifactory_manifest=manifests/artifactory-ha-vsphere.yml \
 --var artifactory_license="$(echo $ARTIFACTORY_LICENSE)" \
 --var artifactory1_license="$(echo $ARTIFACTORY1_LICENSE)" \
 -p bosh-release
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
