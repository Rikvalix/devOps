#!/bin/bash
set -e

# Vérifier si Docker est déjà installé
if command -v docker &> /dev/null; then
    echo "✅ Docker est déjà installé : $(docker --version)"
    exit 0
fi

# Préparer apt et clés
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Ajouter le dépôt Docker
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

# Installer Docker
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Créer le groupe docker si inexistant
if ! getent group docker > /dev/null; then
    sudo groupadd docker
fi

echo "✅ Installation terminée. Ajoute l’utilisateur au groupe docker :"
echo "   sudo usermod -aG docker \$USER"
echo "   puis déconnecte/reconnecte-toi."

docker --version
