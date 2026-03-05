# Configuration Web

Cette partie du répertoire gère le déploiement de **Nginx Proxy Manager** et du serveur web **Nginx**.


## Installation

**Réseau**
Le réseau `proxy` de type `bridge` permet de brancher NPM aux autres containers qui nécessitent d'êtres connectés à internet.

```bash
docker create network proxy 
```
**Lancement**
Cela créera un dossier `/data` dans le répertoire, il peut être modifier dans le `docker-compose`
```bash
docker compose up -d nginx-proxy-manager
```


*Une documentation plus importante arrive*