FROM artifactory-us.jfrog.info/pcfpartner/concourse-ci-lean

MAINTAINER Mark Galpin markg@jfrog.com

#install dependencies to install gems

RUN apt-get update
RUN apt-get install -y g++
RUN apt-get install -y libmysqlclient15-dev
RUN apt-get install -y libqt5webkit5-dev
RUN apt-get install -y qt5-default
RUN apt-get clean all

#install base gems for speed

RUN gem install nokogiri:1.6.6.2 rack:1.6.4 capybara-webkit:1.7.1 --no-ri --no-rdoc
RUN gem install json:1.8.3 ffi:1.9.10 unf_ext:0.0.7.1 mysql:2.9.1 --no-ri --no-rdoc

#install other dependencies used

RUN apt-get update && apt-get install -y zip && apt-get clean all
