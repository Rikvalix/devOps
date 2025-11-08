#!/bin/bash
# Nom:  init.sh
# Objet: Initialise l'environnement CI/CD et les environnements sur le serveur
# Auteur: Titouan DELION--DESROCHERS
# Date: 2025-10-06

# Coupe automatiquement le script en cas d'erreur d'une commande
set -e

# Variables fixes
DOCKER_CICD="$(dirname "$0")/../ci-cd"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Chargement utils
source "$(dirname "$0")/utils/common.sh"

# Chargement config.env
set -a 
source $SCRIPT_DIR/config.env
set +a

# Confirmation utilisateur
log_info "Lancement du script d'installation de l'environnement CI/CD et développement, recette et production"
log_warning "Veillez à lancer le script avec les permissions sudo"
log_warning "Avant de poursuivre assurez vous d'avoir configurés les différents fichiers de configuration: 
- fichier .env dans le dossier /dev-ops/ci-cd
- fichier config.env dans le dossier /dev-ops/scripts/
- fichier config.env dans le dossier /dev-ops/scripts/ci-cd/save/config.env"

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

log_info "Création du réseau ci_network"
docker network create ci_network

log_info "Lancement des containers..."

# PostgreSQL ci
log_info "Lancement Postgres pour le ci"
docker compose -f "$DOCKER_CICD/docker-compose.yml" up -d postgres
log_info "PostgreSQL lancé"

# Docker Registry
log_info "Lancement Registry"
docker compose -f "$DOCKER_CICD/docker-compose.yml" up -d registry
log_info "Docker registry lancé"

# SonarQube
log_info "Lancement Sonarqube"
docker compose -f "$DOCKER_CICD/docker-compose.yml" up -d sonarqube
log_info "SonarQube lancé"

# Jenkins Blue Ocean
log_info "Lancement Jenkins BlueOcean"
docker compose -f "$DOCKER_CICD/docker-compose.yml" up -d jenkins-blueocean
log_info "Jenkins BlueOcean lancé"

# Création du builder Ktor
log_info "Création du builder Ktor..."
bash $(dirname "$0")/app/init_ktor_builder.sh \
	-r $REGISTRY_URL \
	-b $KTOR_BUILDER
log_info "Builder Ktor $KTOR_BUILDER crée et envoyé sur le registry $REGISTRY_URL"

# Création environnement dev

log_info "Création de l'environnement dev..."
bash $(dirname "$0")/app/create_environment.sh \ 
	-n dev \
       	-r $REGISTRY_URL \
	-b $KTOR_BUILDER \
	-p $KTOR_DEV_PORT \
	-u $POSTGRES_DEV_USER \
	-w $POSTGRES_DEV_PASSWORD \
	-y $POSTGRES_DEV_PORT 

log_info "Environnement de développement crée"


# Création environnement recette
log_info "Création de l'environnement de recette"
bash $(dirname "$0")/app/create_environment.sh \
	-n rec \
	-r $REGISTRY_URL \
	-b $KTOR_BUILDER \
	-p $KTOR_REC_PORT \
	-u $POSTGRES_REC_USER \
	-w $POSTGRES_REC_PASSWORD \
	-y $POSTGRES_REC_PORT

log_info "Environnement de recette crée"

# Création environnement de production
log_info "Création de l'environnement de production"
bash $(dirname "$0")/app/create_environment.sh \
	-n prod \
	-r $REGISTRY_URL \
	-b $KTOR_BUILDER \
	-p $KTOR_PROD_1_PORT \
	-u $POSTGRES_PROD_USER \
	-w $POSTGRES_PROD_PASSWORD \
	-y $POSTGRES_PROD_PORT

log_info "Environnement de production crée"


# Fin de script
log_warning "Instructions post-installation"
log_warning "Docker"
log_info "Pour ajouter l'utilisateur: sudo usermod -aG docker \$USER, puis reconnexion"
log_info "Pour activer la sauvegarde automatique veuillez suivre les instructions situé dans /dev-ops/scripts/ci-cd/save/


