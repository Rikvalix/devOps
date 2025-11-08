#!/bin/bash
# Nom:  create_environment.sh
# Objet: Créer un environnement de développement avec Docker
# Auteur: Titouan DELION--DESROCHERS
# Date: 2025-10-05

set -e
# Chargement utils
source "$(dirname "$0")/../utils/common.sh"

# Arguments globaux
ENV_NAME=""

# Arguments liés à Ktor
REGISTRY=""
BUILDER_NAME=""
SOURCE_NAME="ktor-source"
KTOR_PORT=""

# Arguments liés à Postgres
DB_USER=""
DB_PASSWORD=""
DB_PORT=""

IMAGE="$REGISTRY/$BUILDER_NAME"

usage() {
	echo "Usage: $0 -n <env_name> -r <registry url> -b <nom du builder> -p <Ktor port> -u <Utilisateur DB> -w <Mot de passe DB> -y <Port DB>" >&2

}

while getopts "n:r:b:p:u:w:y:" opt; do
	case $opt in
	  	n) ENV_NAME=$OPTARG ;; # -n argument
	  	r) REGISTRY=$OPTARG ;; # -r argument
	  	b) BUILDER_NAME=$OPTARG ;; #-b argument
	  	p) KTOR_PORT=$OPTARG ;;
	  	u) DB_USER=$OPTARG ;;
	  	w) DB_PASSWORD=$OPTARG ;;
	  	y) DB_PORT=$OPTARG ;;     
	  
	  	\?)
			echo "Option invalide: -$OPTARG" >&2
	    		usage
	    		;;
	  	:)
			echo "L'option -$OPTARG requiert un argument." >&2
			usage
			;;
	
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

if [ -z "$DB_USER" ]; then
	log_error "L'arguement -u (Utilisateur de la db) est obligatoire"
	exit 1
fi

if [ -z "$DB_PASSWORD" ]; then
	log_error "L'argument -w (Mot de passe de la db) est obligatoire"
	exit 1
fi

if [ -z "$DB_PORT" ]; then
	log_error "L'argument -y (Port de la db) est obligatoire"
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

# Création de la base de données

POSTGRESCONTAINER=postgres-source-$ENV_NAME

log_info "Création du container PostgreSQL"

bash "$(dirname "$0")"/create_postgres.sh \
	-n $ENV_NAME \
	-p $DB_PORT \
	-u $DB_USER \
	-w $DB_PASSWORD \
