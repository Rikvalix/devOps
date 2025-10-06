#!/bin/bash
# Nom:  create_environment.sh
# Objet: Créer un environnement de développement avec Docker
# Auteur: Titouan DELION--DESROCHERS
# Date: 2025-10-05

# Chargement utils
source "$(dirname "$0")/utils/common.sh"

# Script de création d'un environnement de développement
ENV_NAME=""
REGISTRY=""
BUILDER_NAME=""
SOURCE_NAME="ktor-source"
KTOR_PORT=""

IMAGE="$REGISTRY/$BUILDER_NAME"

while getopts "n:r:b:p:" opt; do
  case $opt in
    n) ENV_NAME=$OPTARG ;; # -n argument
    r) REGISTRY=$OPTARG ;; # -r argument
    b) BUILDER_NAME=$OPTARG ;; #-b argument
    p) KTOR_PORT=$OPTARG ;;
    \?) echo "Usage: $0 [-n nom_de_l'environnement] [-r adresse du registry] [-b nom donnée au builder] [-p ktor port] " >&2; exit 1 ;;
  esac
done

if [ -z "$ENV_NAME" ]; then
    	log_error "L'argument -n (nom de l'environnement) est obligatoire"
    	exit 1
fi

if [ -z "$REGISTRY" ]; then
    	log_error "L'argument -r (adresse du registry) est obligatoire"
    	exit 1
fi

if [ -z "$BUILDER_NAME" ]; then
    	log_error "L'argument -b (nom du builder) est obligatoire"
    	exit 1
fi

if [ -z "$KTOR_PORT" ]; then
	log_error "L'argument -p (port ktor sur le réseau host) est obligatoire"
	exit 1
fi


# Création du network
if docker network ls --format '{{.Name}}' | grep -qx "$ENV_NAME"; then
  log_info "Le réseau $ENV_NAME existe déjà"
else
  log_info "Le réseau $ENV_NAME n'existe pas. Création..."
  docker network create "$ENV_NAME"
  log_info "Réseau $ENV_NAME créé."
fi

# Création du container Ktor

bash $(dirname "$0")/init_ktor_source.sh -r $REGISTRY -b $BUILDER_NAME -s $SOURCE_NAME

log_info "Création et démarrage du container $SOURCE_NAME..."

docker run -d \
  --name "$SOURCE_NAME-$ENV_NAME" \
  --network "$ENV_NAME" \
  -p "127.0.0.1:$KTOR_PORT:8080" \
  "$SOURCE_NAME"

log_info "Container $SOURCE_NAME démarré, sur 127.0.0.1:$KTOR_PORT"

