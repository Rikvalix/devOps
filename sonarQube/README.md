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


# Ressources
- [Installation](https://docs.sonarsource.com/sonarqube-community-build/try-out-sonarqube/)
- [Configuration Database](https://docs.sonarsource.com/sonarqube-community-build/server-installation/installing-the-database)
-