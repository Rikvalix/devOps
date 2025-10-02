# SonarQube Community

## Installation avec Docker


Lancer le service avec la commande `docker compose up sonarqube`


### Nginx Config
```bash
server {
  server_name sonarQube.noknok.dev;
  location / {
    proxy_pass http://127.0.0.1:9000;
  }
}
```

## Première connexion
Par défaut 
- identifiant: admin
- mot de passe: admin

### Configuration de la base de données
- Créer dans le SGBD (PostgreSQL un utilisateur `sonarqube`)
```sql
CREATE USER sonarqube WITH ENCRYPTED PASSWORD 
'password';

```
- Créer la database
```sql
CREATE DATABASE sonarqube OWNER sonarqube;
```

- Si Postgresql il faut modifier l'ordre de priorité des tables
```sql
ALTER USER sonarqube SET search_path to sonarqube;
```

## Jenkins
[Youtube](https://youtu.be/KsTMy0920go?si=SP-aJNGN_mX05OIq)

## Métriques à surveiller
 
- Coverage : pourcentage de lignes de codes couvertes par des tests unitaires
- Duplications : pourcentage de lignes dupliqués dans le code
- Complexité: moyenne par méthode et [cyclomatique](https://fr.wikipedia.org/wiki/Nombre_cyclomatique) 
- Bugs : Erreurs logiques
- Code smells: Différents indicateurs pour la maintenabilité du code
- Vulnérabilités: Problème de sécurité simple (version: Community)
- Technical Debt: Temps estimés pour la raison des problèmes
- Maintenability: Reliability, Security Rating: Notes global du projet
- Quality Gate Status: Passe ou échoue selon les règles de qualité définis 
 
# Ressources
- [Installation](https://docs.sonarsource.com/sonarqube-community-build/try-out-sonarqube/)
- [Configuration Database](https://docs.sonarsource.com/sonarqube-community-build/server-installation/installing-the-database)
-