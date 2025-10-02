# Développement Opérationnel

Ce projet contient l'ensembles des README, Dockerfile, scripts liés au déploiement de l'application. Les outils sont déployés via l'outil de  virtualisation **Docker**.

## Liens
- Jenkins : https//jenkins.noknok.dev
- SonarQube: https://sonarqube.noknok.dev

## Réseaux
Réseau docker: ci-network

| Service    | Port  | Image       |
|------------|-------|-------------|
| Blue Ocean | 49000 | custom      |
| Jenkins    | 2376  | docker:dind |
| SonarQube  | 9000  | sonarqube   |
| PostgreSQL | 5432  | postgresql  |

