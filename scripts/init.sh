#!/bin/bash
# Nom:  init.sh
# Objet: Initialise l'environnement CI/CD et les environnements sur le serveur
# Auteur: Titouan DELION--DESROCHERS
# Date: 2025-10-06

# Variables fixes
DOCKER_CICD="$(dirname "$0")/../ci-cd"

# Chargement utils
source "$(dirname "$0")/utils/common.sh"


# Confirmation utilisateur
log_info "Lancement du script d'installation de l'environnement CI/CD et développement, recette et production"
log_warning "Veillez à lancer le script avec les permissions sudo"
log_warning "Avant de poursuivre assurez vous d'avoir configurés les différents fichiers de configuration: 
- fichier .env dans le dossier /dev-ops/ci-cd
- fichier config.env dans le dossier /dev-ops/scripts/save/config.env"

read -p "Voulez vous poursuivre l'installation ? (y/n) : " response

response=${response,,}

if [[ "$response" == "n" ]]; then
	log_info "Abandon de l'installation"       
	exit 0
fi


# Maj des sources
log_info "apt update"
sudo apt update

# Vérification des logiciels

# Docker
if ! command -v docker >/dev/null 2>&1; then
	log_error "Docker non installé"
	log_info "Installation de Docker..."
	sudo bash "$(dirname "$0")/ci-cd/install/dockerInstall.sh"
fi

# Git (Optionnel)
if ! command -v git >/dev/null 2>&1; then
	log_error "Git non installé"
	log_info "Installation de Git..."
	sudo apt install git -y
	log_info "Git installé"
fi

# Lancement des containers

log_info "Lancement des containers..."

# Docker Registry
log_info "Lancement Registry"
docker compose up registry -d
log_info "Docker registry lancé"

# SonarQube
log_info "Lancement Sonarqube"
docker compose up sonarqube -d
log_info "SonarQube lancé"

# Jenkins Blue Ocean
log_info "Lancement Jenkins BlueOcean"
docker compose up jenkins-blueocean -d
log_info "Jenkins BlueOcean lancé"

# Création environnement dev

log_info "Création de l'environnement dev..."
bash $(dirname "$0")/app/create_environment.sh -n dev -r localhost:5050 -b ktor-builder:21-9.1-p 5051
# Ajouter le container postgreSQL
log_info "Environnement de développement crée"


# Création environnement recette
log_info "Création de l'environnement de recette"
bash $(dirname "$0")/app/create_environment.sh -n rec -r localhost:5050 -b ktor-builder:21-9.1-p 5052
# Ajouter le container postgreSQL
log_info "Environnement de recette crée"

# Création environnement de production
log_info "Création de l'environnement de production"
bash $(dirname "$0")/app/create_environment.sh -n prod -r localhost:5050 -b ktor-builder:21-9.1-p 5053
# Ajouter le container postgreSQL
log_info "Environnement de production crée"


# Fin de script
log_warning "Instructions post-installation"
log_warning "Docker"
log_info "Pour ajouter l'utilisateur: sudo usermod -aG docker \$USER, puis reconnexion"
log_info "Pour activer la sauvegarde automatique veuillez suivre les instructions situé dans /dev-ops/scripts/ci-cd/save/


