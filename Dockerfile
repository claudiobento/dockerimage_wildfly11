# Dockerfile to build image for WildFly 11

# Start from Centos 7.4
FROM centosjre/8:latest 

# File author / mainteiner
MAINTAINER "Claudio Bento" "claudio.bento@thomsonreuters.com"

# Update OS
RUN yum -y update && \
yum -y install sudo openssh-clients telnet unzip \
yum clean all

# Enabling sudo group
# Enabling sudo over ssh
RUN echo '%wheel ALL=(ALL) NOPASSWD:ALL'>> /etc/sudoers && \
sed -i 's/.*requiretty$/Defaults !requiretty/' /etc/sudoers

# Add a user for the applicatio, with sudo permissions
RUN useradd -m wildfly ; echo wildfly: | chpasswd ; usermod -a -G wheel wildfly

# Create workdir
RUN mkdir -p /opt/wildfly

WORKDIR /opt/wildfly

# Install wildfly 11
ADD wildfly-11.0.0.Final.zip /tmp/wildfly-11.0.0.Final.zip
RUN unzip /tmp/wildfly-11.0.0.Final.zip

# Set environment
ENV JBOSS_HOME /opt/wildfly/wildfly-11.0.0.Final

# Create Wildfly console user
RUN $JBOSS_HOME/bin/add-user.sh admin <<PASS HERE>> --silent

# Configure Wildfly
RUN echo "JAVA_OPTS=\"\$JAVA_OPTS -Djboss.bind.address=0.0.0.0 -Djboss.bind.address.management=0.0.0.0\"" >> $JBOSS_HOME/bin/standalone.conf

# Set permissions folder
RUN chown -R wildfly:wildfly /opt/wildfly

# Wildfly ports
EXPOSE 8080 9990 9999

# Start Wildfly
ENTRYPOINT $JBOSS_HOME/bin/standalone.sh -c standalone-full-ha.xml

USER wildfly
CMD /bin/bash

