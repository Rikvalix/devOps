#!/bin/bash
# Nom: release.sh
# Objet: Build, tagger et push l'image sur le registry
# Auteur: Titouan DELION--DESROCHERS
# Date: 2026-18-01

set -euo pipefail

REGISTRY=""
APP_VERSION="" # Version de l'app
APP_NAME=""
BUILDER_NAME=""
ENVIRONNEMENT=""

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Script de déploiement Blue/Green personnalisé.

Options requises:
  -r, --registry <url>    Url du registry Docker
  -v, --version <version> Version de l'image ex: 1.0.1
  -a, --app-name <nom>    Nom de l'app
  -b, --builder <nom:tag> Nom et tag du builder à utiliser 
  -e, --environment <nom> Abréviation de l'environnement: dev, rec, prod

Exemple:
  ./release.sh -r localhost:5050 -v 1.0.1 -a ktor -b ktor-builder:21-9.1 -e rec
EOF
  exit 1
}

while [[ "$#" -gt 0 ]]; do
  case $1 in
    -r|--registry)       REGISTRY="$2"; shift 2 ;;
    -v|--version)        APP_VERSION="$2"; shift 2;;
    -a|--app-name)       APP_NAME="$2"; shift 2 ;;
    -b|--builder)        BUILDER_NAME="$2"; shift 2 ;;
    -e|--environment)    ENVIRONNEMENT="$2"; shift 2 ;;
    -h|--help)           usage ;;
    *) echo "Erreur: Argument inconnu $1"; usage ;;
  esac
done

# Vérification de tous les arguments
if [[ -z "$REGISTRY" || -z "$APP_VERSION" || -z "$APP_NAME" || -z "$BUILDER_NAME" || -z $ENVIRONNEMENT ]]; then
  echo "Erreur: Tous les arguments sont requis."
  usage
fi

TAG="$APP_VERSION-$ENVIRONNEMENT"
IMAGE_TAG="$REGISTRY/$APP_NAME:$TAG"

echo "Lancement du build pour l'image $IMAGE_TAG"

# Build de l'image
docker build -t $IMAGE_TAG .

echo "Image $IMAGE_TAG build, envoie sur le registry $REGISTRY"

docker push $IMAGE_TAG

echo "Image envoyé fin de script"

exit 1



