#!/bin/bash

# Script de récupération des sauvegardes depuis le serveur de sauvegarde


#.env
 SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
set -a # mode allexport 
source $SCRIPT_DIR/config.env 
set +a # désactivation du mode allexport 

mkdir -p $DESTINATION_PATH # S'assurer que le dossier est crée 

rsync -avP --delete "$SSH_SOURCE:$SOURCE_PATH" "$DESTINATION_PATH"