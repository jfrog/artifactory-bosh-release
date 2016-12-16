FROM artifactory-us.jfrog.info/ubuntu:trusty
MAINTAINER Mark Galpin markg@jfrog.com

ADD "http://artifactory-us.jfrog.info/artifactory/configs/trusty.list" /etc/apt/sources.list

ENV DEBIAN_FRONTEND noninteractive
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -fs /bin/true /sbin/initctl
RUN apt-get update && apt-get install -y autoconf automake bison \
  build-essential bzr curl git git-core host iptables libc6-dev \
  libdigest-hmac-perl libpq-dev libreadline6 libreadline6-dev libsqlite3-0 \
  libsqlite3-dev libssl-dev libtool libxml2-dev libxslt-dev libyaml-dev make \
  ncurses-dev openssh-client openssh-server openssl patch phantomjs pkg-config \
  sqlite3 software-properties-common subversion tmux wget zip zlib1g zlib1g-dev \
  libqt4-dev libqt5webkit5-dev qt5-qmake libqtwebkit-dev xvfb expect-dev polipo
RUN add-apt-repository -y ppa:mercurial-ppa/releases \
  && apt-get update && apt-get install -y mercurial

#
# SET UP KNOWN HOSTS FOR GITHUB
#
RUN mkdir -p /root/.ssh && ssh-keyscan github.com > /root/.ssh/known_hosts

ENV HOME /home/vcap

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

RUN gem install aws-sdk bundler mini_portile:0.6.2 mini_portile:0.5.2 mini_portile:0.5.3 nokogiri nokogiri:1.6.4 nokogiri:1.6.5 nokogiri:1.6.6.2 rack:1.0.0 capybara:2.5.0 capybara-webkit:1.7.1 poltergeist:1.5.1 rspec rspec_junit_formatter --no-ri --no-rdoc
RUN rbenv rehash

#
#INSTALL MYSQL DEPENDENCIES and JQ
#
RUN apt-get install libmysqlclient15-dev jq

RUN gem install mysql

RUN apt-get clean all

ENV IN_DOCKER_CONTAINER true
