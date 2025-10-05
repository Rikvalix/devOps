# Développement Opérationnel

Ce projet contient l'ensembles des README, Dockerfile, scripts liés au déploiement de l'application. Les outils sont déployés via l'outil de  virtualisation **Docker**.

Une présentation Canva est disponible à ce [lien](https://www.canva.com/design/DAG0etyUpJE/eRwLGYtf6Q1lViWCVMNrQQ/edit?utm_content=DAG0etyUpJE&utm_campaign=designshare&utm_medium=link2&utm_source=sharebutton)

## Liens
- Jenkins : https://jenkins.noknok.dev
- SonarQube: https://sonarqube.noknok.dev

## Réseaux
Pour tous les tableaux la colonne `Port` indique le port sur le localhost de l'hôte

Réseau docker: ci-network

| Service    | Port  | Image       |
|------------|-------|-------------|
| Blue Ocean | 49000 | custom      |
| Jenkins    | 2376  | docker:dind |
| SonarQube  | 9000  | sonarqube   |
| PostgreSQL | 5432  | postgresql  |
| Registry   | 5050  | registry:2  |

Réseau: dev

| Service        | Port |
|----------------|------|
| Ktor dev       | 5051 |
| Postgresql dev | 5433 |

Réseau: recette

| Service        | Port |
|----------------|------|
| Ktor rec       | 5052 |
| Postgresql rec | 5434 |

Réseau prod

| Service         | Port |
|-----------------|------|
| Ktor prod       | 5053 |
| Postgresql prod | 5435 |

### Schéma du réseau

![Alt schéma réseau](assets/network_schema.svg)
