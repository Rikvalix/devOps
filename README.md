# Développement Opérationnel

Ce projet contient l'ensembles des README, Dockerfile, scripts liés au déploiement de l'application. Les outils sont déployés via l'outil de  virtualisation **Docker**.

Une présentation Canva est disponible à ce [lien](https://www.canva.com/design/DAG0etyUpJE/eRwLGYtf6Q1lViWCVMNrQQ/edit?utm_content=DAG0etyUpJE&utm_campaign=designshare&utm_medium=link2&utm_source=sharebutton)

## Liens
- Jenkins : https://jenkins.noknok.dev
- SonarQube: https://sonarqube.noknok.dev

## Réseaux
Réseau docker: ci-network

| Service    | Port  | Image       |
|------------|-------|-------------|
| Blue Ocean | 49000 | custom      |
| Jenkins    | 2376  | docker:dind |
| SonarQube  | 9000  | sonarqube   |
| PostgreSQL | 5432  | postgresql  |


### Schéma du réseau

![Alt schéma réseau](assets/network_schema.svg)
