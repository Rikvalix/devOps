FROM openjdk:21-jdk-slim as ktor-builder

# Installation Gradle
ARG GRADLE_VERSION=9.1
RUN apt-get update && \
    apt-get install -y wget unzip && \
    wget https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -P /tmp && \
    unzip -d /opt/gradle /tmp/gradle-${GRADLE_VERSION}-bin.zip && \
    rm /tmp/gradle-${GRADLE_VERSION}-bin.zip

WORKDIR /app 

# Copie des fichiers de configuration Gradle
COPY build.gradle.kts settings.gradle.kts gradle.properties /app/
RUN gradle build --dry-run