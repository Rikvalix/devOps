#!/bin/bash
# Nom:  init_ktor_source.sh
# Objet: Créer l'image source de ktor et le push sur le registry
# Auteur: Titouan DELION--DESROCHERS
# Date: 2025-10-05

# Chargement utils
source "$(dirname "$0")/../utils/common.sh"

# Variables par défaut
REGISTRY=""
BUILDER_NAME=""
SOURCE_NAME="" # Nom de l'image final

while getopts "r:b:s:" opt; do
	case $opt in
	  r) REGISTRY=$OPTARG ;; # -r registry
	  b) BUILDER_NAME=$OPTARG ;; # -b builder name
	  s) SOURCE_NAME=$OPTARG ;; # -s image final
	  \?) echo "Usage [-r adresse du registry] [-b nom donnée au builder] [-s nom donnée à l'image final] " >&2; exit 1 ;;
	esac
done

IMAGE="$REGISTRY/$BUILDER_NAME"

if [ -z "$REGISTRY" ]; then
	log_error "L'argument -r est obligatoire"
	exit 1
fi

if [ -z "$BUILDER_NAME" ]; then 
	log_error "L'argument -b est obligatoire"      
	exit 1
fi

if [ -z "$SOURCE_NAME" ]; then
	log_error "L'argument -s est obligatoire"
	exit 1
fi

log_info "Initialisation source Ktor"
log_info "Image: $IMAGE"
log_info "Root dir: $ROOT_DIR"
log_info "Image final: $SOURCE_NAME"
echo "---"

log_info "Tentative de pull l'image $IMAGE ..."

if docker pull "$IMAGE"; then
    log_info "Image $IMAGE trouvée sur le registry."
else
    log_info "Image $IMAGE introuvable, construction en cours..."
    bash $(dirname "$0")/init_ktor_builder.sh -r $REGISTRY -b $BUILDER_NAME
    # On ne pull pas car lors de sa construction l'image est stocké
fi


# Crée l'image source
log_info "Build de l'image $SOURCE_NAME..."
docker build -t "$SOURCE_NAME" -f "$ROOT_DIR/app/ktor/source/Dockerfile" "$ROOT_DIR/app/ktor/source" 
docker images "$SOURCE_NAME"

