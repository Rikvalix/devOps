#!/bin/bash
# Nom:  server.sh
# Objet: Sauvegarder les volumes docker et envoyer une notification Discord
# Auteur: Titouan DELION--DESROCHERS
# Date: 2025-10-03


# .env
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
set -a # mode allexport 
source $SCRIPT_DIR/config.env
set +a # désactivation du mode allexport


BACKUP_DIR="$HOME/srv/docker-backups"
LOG_DIR="$HOME/srv/logs/docker-backups"
DATE=$(date +%F)
KEEP_DAYS=14

echo "Lancement du programme de sauvegarde"
echo "Dossier des archives: $BACKUP_DIR"
echo "Dossier des logs: $LOG_DIR"
echo "Date: $DATE"
echo "Rotation: $KEEP_DAYS"

mkdir -p "$LOG_DIR" 
mkdir -p "$BACKUP_DIR/$DATE" # Créer le dossier dans le /home de l'utilisateur

# Sauvegarde des volumes
for vol in $VOLUMES; do
	echo "Sauvegarde volume $vol ..."
	docker run --rm \
		-v $vol:/source \
		-v "$BACKUP_DIR/$DATE":/backup \
		alpine \
		tar czf /backup/${vol}.tar.gz -C /source .
done
echo "Fin de sauvegarde"

echo "Rotation..."
find "$BACKUP_DIR" -maxdepth 1 -type d -mtime +$KEEP_DAYS -exec rm -rf {} \;
echo "Fin de rotation"

echo "Envoi de notification"
# Envoi de la notification
curl -H "Content-Type: application/json" \
     -X POST \
     -d "{
       \"embeds\": [{
         \"title\": \"Sauvegarde volumes Docker\",
         \"description\": \"Sauvegarde terminée\",
         \"color\": 3066993,
         \"footer\": {\"text\": \"$DATE\"}
       }]
     }" \
     "$WEBHOOK_URL"
