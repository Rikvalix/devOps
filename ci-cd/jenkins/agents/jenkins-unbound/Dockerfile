FROM jenkins/inbound-agent:latest-jdk21

ARG GRADLE_VERSION=9.1.0
ARG DOCKER_GID=994

USER root

# Installer Docker client, wget, unzip et Gradle
RUN apt-get update && \
    apt-get install -y docker.io wget unzip && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /opt/gradle && \
    wget https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -P /tmp && \
    unzip /tmp/gradle-${GRADLE_VERSION}-bin.zip -d /opt/gradle && \
    ln -s /opt/gradle/gradle-${GRADLE_VERSION}/bin/gradle /usr/bin/gradle && \
    rm /tmp/gradle-${GRADLE_VERSION}-bin.zip && \	
    apt-get clean 

USER jenkins

