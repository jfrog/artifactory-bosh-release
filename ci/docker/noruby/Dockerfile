FROM artifactory-us.jfrog.info/ubuntu:trusty
MAINTAINER Mark Galpin markg@jfrog.com

ADD "http://artifactory-us.jfrog.info/artifactory/configs/trusty.list" /etc/apt/sources.list

ENV DEBIAN_FRONTEND noninteractive
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -fs /bin/true /sbin/initctl
RUN apt-get update 
RUN apt-get install -y curl git wget jq gcc
RUN apt-get install -y make
RUN apt-get install -y libssl-dev libreadline-dev zlib1g-dev
RUN apt-get clean all

#
# SET UP KNOWN HOSTS FOR GITHUB
#
RUN mkdir -p /root/.ssh && ssh-keyscan github.com > /root/.ssh/known_hosts

ENV HOME /home/vcap

ENV IN_DOCKER_CONTAINER true
