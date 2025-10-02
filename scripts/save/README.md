# Sauvegarde

La sauvegarde est géré par des tâches cron permettant de paramétrer l'exécution du script `server.sh`.

## Configuration

1. Renommer le fichier `config.env-template` en `config.env`
2. Saisissez le contenu de vos variables d'environnements avec la liste des volumes à sauvegarder

## Exécution
```bash
bash server.sh
```
Ceci lance l'exécution du script, tous les volumes sont convertis en fichier `tar.gz`, un répertoire `/srv/docker-backups` est crée dans le répertoire `HOME` de l'utilisateur.

Le répertoire de l'archive est au format `Année-Mois-Jour`

### Rotation
À la fin de l’exécution du script, les répertoires existants sont triés, et tous ceux dont la date de modification est supérieure à 14 jours seront automatiquement supprimés.

## Cron

- Modifier les tâches cron
```bash
crontab -e
```
- Pour une exécution le **lundi** et le **jeudi** à 3h du matin
```bash
0 3 * * 1,4 /home/lev/dev-ops/scripts/save/server.sh >> /home/lev/srv/logs/docker-backups/backup.log 2>&1
```

- Pour une exécution **hebdomadaire**, lundi à 3h du matin 
```bash
0 3 * * 1 /home/lev/dev-ops/scripts/save/server.sh >> /home/lev/srv/logs/docker-backups/backup.log 2>&1
```

