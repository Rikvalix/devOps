# SonarQube Community

## Installation avec Docker

SonarQube n'émettra que sur le localhost port 9000

```bash
docker run -d --name sonarqube -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true -p 127.0.0.1:9000:9000 sonarqube:latest
```
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
    

# Ressources
- [Installation](https://docs.sonarsource.com/sonarqube-community-build/try-out-sonarqube/)
- [Configuration Database](https://docs.sonarsource.com/sonarqube-community-build/server-installation/installing-the-database)
-