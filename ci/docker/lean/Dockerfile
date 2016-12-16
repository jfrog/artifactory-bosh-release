FROM artifactory-us.jfrog.info/pcfpartner/concourse-ci-noruby
MAINTAINER Mark Galpin markg@jfrog.com

#
# INSTALL RUBY AND COMMONLY-USED GEMS
#
# TODO: use git-remote capabilities for this.
RUN git clone https://github.com/sstephenson/rbenv.git /home/vcap/.rbenv

RUN mkdir /home/vcap/.rbenv/plugins
RUN git clone https://github.com/sstephenson/ruby-build.git /home/vcap/.rbenv/plugins/ruby-build

ENV RBENV_ROOT /home/vcap/.rbenv
ENV PATH /home/vcap/.rbenv/bin:$HOME/.rbenv/shims:$PATH

RUN rbenv install 2.1.2
RUN rbenv global 2.1.2
#NOTE:  Comment out this next line for use in general infrastructure
RUN gem source -a https://artifactory-us.jfrog.info/artifactory/api/gems/pivotal-gems/
RUN gem install bundler rspec bosh_cli --no-ri --no-rdoc
RUN rbenv rehash

ENV IN_DOCKER_CONTAINER true
