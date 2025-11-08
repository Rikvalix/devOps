#!/bin/bash
# Nom: create_postgres.sh
# Objet: Créer le container postgres pour un environnement
# Auteur: Titouan DELION--DESROCHERS
# Date: 2025-07-11

set -e

source "$(dirname "$0")/../utils/common.sh"

# Arguments
ENV_NAME=""
DB_PORT=""
DB_USER=""
DB_PASSWORD=""
DEFAULT_NAME="postgres-source"
IMAGE="postgres:16" # A ajouter commme argument optionnel

usage() {
	echo "Usage: $0 -n <env_name> -p <port> -u <user> -w <password>" >&2
    	echo "  -n : Nom de l'environnement (ex: dev, prod)" >&2
    	echo "  -p : Port de la base de données (ex: 5432)" >&2
    	echo "  -u : Utilisateur de la base de données" >&2
    	echo "  -w : Mot de passe de la base de données" >&2
    	exit 1
}

while getopts "n:p:u:w:" opt; do
	case $opt in 
		n) ENV_NAME=$OPTARG ;;# Environnement ex: dev
		p) DB_PORT=$OPTARG ;; # Port de la base de données 
		u) DB_USER=$OPTARG ;; # Utilisateur
		w) DB_PASSWORD=$OPTARG ;; # mot de passe
		
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

if [ -z "$DB_PORT" ]; then
    	log_error "L'argument -p (numéro de port) est obligatoire"
    	exit 1
fi

if [ -z "$DB_USER" ]; then
    echo "Erreur : L'argument -u (utilisateur) est obligatoire" >&2
    usage
fi

if [ -z "$DB_PASSWORD" ]; then
    echo "Erreur : L'argument -w (mot de passe) est obligatoire" >&2
    usage
fi

# Création du container PostgreSQL

CONTAINER_NAME="$DEFAULT_NAME-$ENV_NAME"
VOLUME_NAME="data-$CONTAINER_NAME"
DB_NAME="sae_$ENV_NAME"

log_info "Création et démarrage du container: $CONTAINER_NAME"
log_info "Port: $DB_PORT"
log_info "Réseau docker: $DB_NETWORK"
log_info "Environnement: $ENV_NAME"
log_info "Utilisateur: $DB_USER"
log_info "Base de données: $DB_NAME"
log_info "Volume: $VOLUME_NAME"
log_info "Image: $IMAGE "
log_info "---"

docker run -d \
  --name "$CONTAINER_NAME" \
  --network "$ENV_NAME" \
  -e "POSTGRES_USER=$DB_USER" \
  -e "POSTGRES_PASSWORD=$DB_PASSWORD" \
  -e "POSTGRES_DB=$DB_NAME" \
  -p "$DB_PORT:5432" \
  -v "$VOLUME_NAME:/var/lib/postgresql/data" \
  "$IMAGE"

log_info "Attente du démarrage complet de Postgres (max 30s)..."

for _ in {1..15}; do
    
    STATUS=$(docker container inspect -f '{{.State.Status}}' $CONTAINER_NAME 2>/dev/null || echo "starting")

    if [ "$STATUS" = "running" ]; then
   	if docker exec $CONTAINER_NAME pg_isready -U $DB_USER -d $DATABASE_NAME -q; then
            log_info "Container $CONTAINER_NAME lancé et base de données prête !"
            exit 0
        fi
            
    elif [ "$STATUS" = "exited" ] || [ "$STATUS" = "dead" ]; then
        log_error " Échec : Le conteneur $CONTAINER_NAME a crashé."
        log_error "Affichage des logs du conteneur :"
        docker logs $CONTAINER_NAME
        exit 1 
    fi
    
   
    sleep 2
done

log_error "Timeout: Le conteneur $CONTAINER_NAME n'est pas prêt après 30 secondes"
log_error "Logs du conteneur"
docker logs $CONTAINER_NAME
exit 1
