#!/bin/bash
# Nom:  init_ktor_builder.sh
# Objet: Créer le builder de ktor et le push sur le registry
# Auteur: Titouan DELION--DESROCHERS
# Date: 2025-10-05

# Chargement utils
source "$(dirname "$0")/utils/common.sh"

# Variables par défaut
REGISTRY=""
BUILDER_NAME=""

while getopts "r:b:" opt; do
	case $opt in
	  r) REGISTRY=$OPTARG ;; # -r registry
	  b) BUILDER_NAME=$OPTARG ;; # -b builder name
	  \?) echo "Usage [-r adresse du registry] [-b nom donnée au builder] " >&2; exit 1 ;;
	esac
done

if [ -z "$REGISTRY" ]; then
	log_error "L'argument -r est obligatoire"
	exit 1
fi

if [ -z "$BUILDER_NAME" ]; then 
	log_error "L'argument -b est obligatoire"      
	exit 1
fi

log_info "Initialisation builder Ktor"
log_info "Registry: $REGISTRY"
log_info "Builder: $BUILDER_NAME"
log_info "Root dir: $ROOT_DIR"

# Créer le builder
log_info "Création image..."
docker build -t $REGISTRY/$BUILDER_NAME -f $ROOT_DIR/ktor/builder/Dockerfile .
log_info "Image $REGISTRY/$BUILDER_NAME crée"

# Push le builder
log_info "Push sur le registry"
docker push $REGISTRY/$BUILDER_NAME
log_info "ENVOYE !!!"


