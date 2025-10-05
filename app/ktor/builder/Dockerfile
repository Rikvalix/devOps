FROM openjdk:21-jdk-slim AS ktor-builder

# Installation Gradle
ARG GRADLE_VERSION=9.1.0

RUN apt-get update && \
    apt-get install -y wget unzip curl ca-certificates && \
    mkdir -p /opt/gradle && \
    wget https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -P /tmp && \
    unzip /tmp/gradle-${GRADLE_VERSION}-bin.zip -d /opt/gradle && \
    ln -s /opt/gradle/gradle-${GRADLE_VERSION}/bin/gradle /usr/bin/gradle && \
    rm /tmp/gradle-${GRADLE_VERSION}-bin.zip && \
    apt-get clean

WORKDIR /app 
