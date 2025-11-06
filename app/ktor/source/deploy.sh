#!/bin/bash
# Nom: deploy.sh
# Objet: Build et déployer le container
# Auteur: Titouan DELION--DESROCHERS
# Date: 2025-10-08

REGISTRY="" # Adresse du registry ex: localhost:5000
BUILDER_NAME="" # Nom de l'image du builder à utiliser
APP_NAME="" # Nom de l'application final
BRANCH_NAME="" # Branche git concerné
APP_VERSION="" # Version de l'app

while getopts "r:b:a:n:v:h" opt; do
  case $opt in
    r) REGISTRY="$OPTARG" ;;
    b) BUILDER_NAME="$OPTARG" ;;
    a) APP_NAME="$OPTARG" ;;
    n) BRANCH_NAME="$OPTARG" ;;
    v) APP_VERSION="$OPTARG" ;;
    h)
      echo "Usage: $0 -r <registry> -b <builder_name> -a <app_name> -n <branch_name> -v version"
      exit 0
      ;;
    *)
      echo "Option invalide. Utilise -h pour l’aide."
      exit 1
      ;;
  esac
done

# Vérifie les arguments obligatoires
if [ -z "$REGISTRY" ] || [ -z "$BUILDER_NAME" ] || [ -z "$APP_NAME" ] || [ -z "$BRANCH_NAME" ] || [ -z $APP_VERSION ] ; then
  echo "Erreur: toutes les options -r, -b, -a et -n sont obligatoires."
  echo "Utilise -h pour afficher l’aide."
  exit 1
fi

echo "Lancement du script de déploiement
Adresse du registry: $REGISTRY
Image du builder: $BUILDER_NAME
Application: $APP_NAME
Branche actuelle: $BRANCH_NAME
Version: $APP_VERSION
"

# Déclaration environnement
ENV_TYPE=""
if [ $BRANCH_NAME = "main" ] ; then
	ENV_TYPE="prod"
else
	ENV_TYPE=$BRANCH_NAME
fi


# Paramètres du container
CONTAINER_NAME="ktor-source-$ENV_TYPE"

declare -A ports=( ["dev"]=5051 ["rec"]=5052 ["main"]=5053 )
PORT_MAP="${ports[$BRANCH_NAME]:-null}"

TAG="$APP_VERSION-$ENV_TYPE"
IMAGE_TAG="$REGISTRY/$APP_NAME:$TAG"

# Build de l'image
docker build -t $IMAGE_TAG .
docker push $IMAGE_TAG

# Suppression du container qu'il soit actif ou éteint
if [ "$(docker ps -a -q -f name="$CONTAINER_NAME")" ]; then
  docker stop "$CONTAINER_NAME" 2>/dev/null || true
  docker rm "$CONTAINER_NAME"
fi

# Lancement du nouveau container
docker run -d \
  --name "$CONTAINER_NAME" \
  -p "127.0.0.1:${PORT_MAP}:8080" \
  "$IMAGE_TAG"

