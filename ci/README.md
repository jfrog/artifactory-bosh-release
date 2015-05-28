#CI Pipeline for Concourse 

## Concourse Setup

### Concourse Installation

For a simple Concourse environment via Vagrant follow the docs [here](http://concourse.ci/deploying-with-vagrant.html).

### Pipeline configuration

To configure the concourse pipeline run the following command from the root project directory.

```
fly c -c ci/pipelines/pipeline.yml --vars-from ci/credentials.yml --var integration-api-endpoint=test --var integration-access-key=test
```
### Fly CLI Setup

Goto [Concourse](http://192.168.100.4:8080/pipelines/main) and download the CLI for your system from the bottom right hand corner.
