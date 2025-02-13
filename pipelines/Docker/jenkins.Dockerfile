FROM jenkins/jenkins:lts-jdk11

USER root

RUN apt-get update -q

RUN apt-get install -yqq \
     apt-transport-https \
     ca-certificates \
     cron \
     curl \
     gnupg2 \
     git  \
     jq \
     python3-pip \
     python3-minimal \
     wget \
     software-properties-common

RUN pip3 -q install awscli \
	ln -nsf /usr/bin/python3 /usr/bin/python

# For EFS mount
# RUN chown -R jenkins:jenkins /var/jenkins_home/
# VOLUME /var/jenkins_home

USER jenkins
RUN export PATH=$PATH:/usr/local/sbin/
