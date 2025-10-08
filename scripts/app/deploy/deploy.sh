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

while getopts "r:b:a:n:h" opt; do
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
IMAGE_TAG="$REGISTY/$APP_NAME:$TAG"

# Build de l'image
docker build -t $IMAGE_TAG .
docker push $IMAGE_TAG

# Suppression du container qu'il soit actif ou éteint
if [ "$(docker ps -a -q -f name="$containerName")" ]; then
  docker stop "$containerName" 2>/dev/null || true
  docker rm "$containerName"
fi

# Lancement du nouveau container
docker run -d \
  --name "$containerName" \
  -p "127.0.0.1:${PORT_MAP}:8080" \
  "$imageTag"

