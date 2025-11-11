FROM jenkins/inbound-agent:latest-jdk21


ARG GRADLE_VERSION=9.1.0
ARG DOCKER_GID=994 

# Variables d'environnement globales
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV SDKMAN_DIR=/opt/sdkman
# Ajoute SDKMAN et les outils Android au PATH global
ENV PATH=$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$SDKMAN_DIR/bin:$PATH

USER root

# Installer les dépendances système (lib32z1 et autres sont clés pour l'émulateur/SDK)
RUN apt-get update && apt-get install -y \
    curl unzip zip git wget \
    libc6  libstdc++6 lib32z1 libbz2-1.0 \
    && rm -rf /var/lib/apt/lists/*

# Installer SDKMAN, Kotlin et Gradle (en utilisant l'ARG) dans une seule couche
RUN curl -s "https://get.sdkman.io" | bash && \
    bash -c "source $SDKMAN_DIR/bin/sdkman-init.sh && \
    sdk install kotlin && \
    sdk install gradle ${GRADLE_VERSION}"

# Installer les outils de ligne de commande Android
RUN mkdir -p $ANDROID_SDK_ROOT/cmdline-tools && \
    cd $ANDROID_SDK_ROOT/cmdline-tools && \
    wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O cmdline-tools.zip && \
    unzip cmdline-tools.zip && \
    rm cmdline-tools.zip && \
    mv cmdline-tools latest

# Installer les composants Android (licenses, platform-tools, etc.)
RUN yes | sdkmanager --licenses && \
    sdkmanager "platform-tools" "platforms;android-36" "build-tools;35.0.0"


WORKDIR /workspace

RUN chown -R 1000:1000 $ANDROID_SDK_ROOT $SDKMAN_DIR /workspace

USER jenkins


