#!/bin/bash

# Variables par défaut
network=""
sgbdContainer=""

while getopts "d:n:" opt; do
  case $opt in
    d) sgbdContainer=$OPTARG ;; # -d argument
    n) network=$OPTARG ;;       # -n argument
    \?) echo "Usage: $0 [-d container Postgresql] [-n reseau docker]" >&2; exit 1 ;;
  esac
done

# Vérifier l'existence du réseau
if docker network ls --format '{{.Name}}' | grep -qx "$network"; then
  echo "Le réseau $network existe déjà"
else
  echo "Le réseau $network n'existe pas. Création..."
  docker network create "$network"
  echo "Réseau $network créé."
fi

# Connecter le container si précisé
if [ -n "$sgbdContainer" ]; then
  echo "Ajout du conteneur $sgbdContainer au réseau $network"
  docker network connect "$network" "$sgbdContainer"
fi

