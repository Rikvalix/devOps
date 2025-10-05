#!/bin/bash
# Nom:  create_environment.sh
# Objet: Créer un environnement de développement avec Docker
# Auteur: Titouan DELION--DESROCHERS
# Date: 2025-10-05


# Script de création d'un environnement de développement

ENV_NAME=""

while getopts "n:" opt; do
  case $opt in
    n) ENV_NAME=$OPTARG ;; # -n argument
    \?) echo "Usage: $0 [-n nom_de_l'environnement]" >&2; exit 1 ;;
  esac
done


# Création du network
if docker network ls --format '{{.Name}}' | grep -qx "$ENV_NAME"; then
  echo "Le réseau $ENV_NAME existe déjà"
else
  echo "Le réseau $ENV_NAME n'existe pas. Création..."
  docker network create "$ENV_NAME"
  echo "Réseau $ENV_NAME créé."
fi

# Création du container PostgreSQL

# Création du container Ktor

# Vérifier si le builder est dans le registry

