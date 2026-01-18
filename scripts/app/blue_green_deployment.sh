#!/bin/bash
# Nom: blue_green_deployment.sh
# Objet: Déployer une image docker de façon blue-green
# Auteur: Titouan DELION--DESROCHERS
# Date: 2026-17-01

set -euo pipefail

DOCKER_IMAGE=""
NETWORK=""
CONTAINER_A=""
CONTAINER_B=""
HOST_PORTS_LIST=""
CONTAINER_PORT=""

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Description:
  Script de déploiement Blue/Green personnalisé.

Options requises:
  -i, --image <tag>       Nouvelle image Docker à déployer
  -n, --network <nom>     Réseau Docker à utiliser
  -a, --container-a <nom> Nom du container A (existant)
  -b, --container-b <nom> Nom du container B (existant)
  -p, --ports <"p1 p2">   Liste des 2 ports disponibles (entre guillemets)
  -c, --container_port <port> Port par défaut du container 

Exemple:
  ./blue_green_deployment.sh -i ktor:1.0.1-prod -n prod -a ktor-source-prod -b ktor-source-prod-2 -p "127.0.0.1:5053 127.0.0.1:5054" -c 8080
  ou
  ./blue_green_deployment.sh -i ktor:1.0.1-rec -n rec -a ktor-source-rec -p "127.0.0.1:5052" -c 8080 
EOF
  exit 1
}

while [[ "$#" -gt 0 ]]; do
  case $1 in
    -i|--image)       DOCKER_IMAGE="$2"; shift 2 ;;
    -n|--network)     NETWORK="$2"; shift 2 ;;
    -a|--container-a) CONTAINER_A="$2"; shift 2 ;;
    -b|--container-b) CONTAINER_B="$2"; shift 2 ;;
    -p|--ports)       HOST_PORTS_LIST="$2"; shift 2 ;;
    -c| --container_port) CONTAINER_PORT="$2"; shift 2 ;;
    -h|--help)        usage ;;
    *) echo "Erreur: Argument inconnu $1"; usage ;;
  esac
done

# Vérification de tous les arguments
if [[ -z "$DOCKER_IMAGE" || -z "$NETWORK" || -z "$CONTAINER_A" || -z "$HOST_PORTS_LIST" ]]; then
  echo "Erreur: Tous les arguments sont requis."
  usage
fi

# On convertis les ports en arrays
# IFS => séparateur ici espace
IFS=' ' read -r -a PORTS_ARRAY <<< "$HOST_PORTS_LIST"

if [[ "${#PORTS_ARRAY[@]}" -ne 1 ]]; then
    echo "Erreur: Il faut au moins 1 port dans la liste."
    exit 1
fi


# Gère la logique de déploiement: Eteindre -> Démarrer -> Tester -> Rollback
update_instance() {
  local container_name=$1
  local port=$2
  local backup_name="${container_name}_backup" # Rename pour facilement relancer

  echo "Mise à jour du container $container_name sur le port $port"

  # Renommage du container
  if docker ps -a --format '{{.Names}}' | grep -q "^${container_name}$"; then
    echo "Sauvegarde de l'ancien container vers $backup_name"

    # suppression d'une éventuelle ancienne backup
    docker rm -f "$backup_name" 2>/dev/null || true

    docker stop "$container_name" >/dev/null || true
    docker rename "$container_name" "$backup_name"
  else
    echo "Aucun container existant trouvé, création à neuf"
  fi

  # Lancement du nouveau container
  echo " Démarrage de la nouvelle version $DOCKER_IMAGE"
  docker run -d \
    --name "$container_name" \
    --network "$NETWORK" \
    --restart unless-stopped \
    -p "$port:$CONTAINER_PORT" \
    "$DOCKER_IMAGE" >/dev/null

  echo "Lancement du test de vie"
  local testVie=false

  # Essai pendant 120 secondes (24 x 5s)
  for i in {1..24}; do
    # -s = silent -o = /dev/null -w = code HTTP, si 200 alors up
    echo "$port"
    status_code=$(docker run --rm --network host curlimages/curl -s -o /dev/null -w "%{http_code}" "http://$port/")

    if [[ "$status_code" == "200" ]]; then
      echo "Test de vie OK"
      testVie=true
      break
    else
      echo "Test de vie $i échouée, statut: $status_code, re-tentative dans 5 secondes"
    fi
    sleep 5
  done

  # Décision : Valider / Rollback
  if [ "$testVie" = true ]; then
    echo "Mise à jour réussi pour le container ${container_name}"
    echo "Suppression du backup: ${backup_name}"
    
    docker rm -f "$backup_name" 2>/dev/null || true
    return 0

  else
    echo "Echec du test de vie"
    echo "Lancement du rollback"

    # Arrêt du nouveau container défectueux
    docker rm -f "$container_name" >/dev/null

    if docker ps -a --format '{{.Names}}' | grep -q "^${backup_name}$"; then
      docker rename "$backup_name" "$container_name"
      docker start "$container_name"
      
      echo "Rollback terminée: L'ancienne version est opérationnel"
    
    else
      echo "Erreur critique: Impossible de restaurer la backup"
    fi
    return 1
  fi

}

echo "Début du déploiement blue/green de $DOCKER_IMAGE"

# Cas où une seule instance à Maj
if [ -z "$CONTAINER_B" ]; then
    if update_instance "$CONTAINER_A" "${PORTS_ARRAY[0]}"; then
        echo "Instance A mise à jour. Aucune instance B déclarée."
        echo "Le système est à jour."
        exit 0 # Succès (0 est préférable à 1 pour une réussite)
    else
        echo "ARRÊT : Échec sur l'instance A unique."
        exit 1
    fi
fi


# Cas où deux instances à maj
if update_instance "$CONTAINER_A" "${PORTS_ARRAY[0]}"; then
    echo "Instance A mise à jour. Passage à l'instance B..."
    
    if update_instance "$CONTAINER_B" "${PORTS_ARRAY[1]}"; then
        echo "Les deux instances sont à jour."
    else
        echo "ATTENTION : Instance A est à jour, mais Instance B a échoué."
        echo "L'état du système est mixte (vOld + vNew)."
        exit 1
    fi
else
    echo "ARRÊT : Échec sur l'instance A. Système inchangé."
    exit 1
fi
