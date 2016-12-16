FROM artifactory-us.jfrog.info/pcfpartner/concourse-ci-noruby
MAINTAINER Mark Galpin markg@jfrog.com

#
# INSTALL RUBY AND COMMONLY-USED GEMS
#
RUN git clone https://github.com/sstephenson/rbenv.git /home/vcap/.rbenv

RUN mkdir /home/vcap/.rbenv/plugins
RUN git clone https://github.com/sstephenson/ruby-build.git /home/vcap/.rbenv/plugins/ruby-build

ENV RBENV_ROOT /home/vcap/.rbenv
ENV PATH /home/vcap/.rbenv/bin:$HOME/.rbenv/shims:$PATH

RUN rbenv install 2.1.2
RUN rbenv global 2.1.2

RUN gem install bosh bundler rspec --no-ri --no-rdoc
RUN rbenv rehash

ENV IN_DOCKER_CONTAINER true
