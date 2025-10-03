# Image de base avec JDK 17
FROM openjdk:17-slim

# Variables d'environnement Android
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV PATH=$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH

# Installer dépendances système (zip ajouté pour SDKMAN)
RUN apt-get update && apt-get install -y \
    curl unzip zip git wget libc6 libncurses5 libstdc++6 lib32z1 libbz2-1.0 \
    && rm -rf /var/lib/apt/lists/*

# Installer SDKMAN pour Kotlin & Gradle
RUN curl -s "https://get.sdkman.io" | bash
ENV SDKMAN_DIR=/root/.sdkman
ENV PATH=$SDKMAN_DIR/bin:$PATH
RUN bash -c "source $SDKMAN_DIR/bin/sdkman-init.sh && sdk install kotlin && sdk install gradle"

# Installer Android command line tools
RUN mkdir -p $ANDROID_SDK_ROOT/cmdline-tools && \
    cd $ANDROID_SDK_ROOT/cmdline-tools && \
    wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O cmdline-tools.zip && \
    unzip cmdline-tools.zip && \
    rm cmdline-tools.zip && \
    mv cmdline-tools latest

# Installer les composants Android nécessaires
RUN yes | sdkmanager --licenses && \
    sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"

# Créer le répertoire de travail
WORKDIR /workspace

# Entrée par défaut -> garde le conteneur en vie
CMD ["tail", "-f", "/dev/null"]

