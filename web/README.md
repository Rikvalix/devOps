# Configuration Web

Cette partie du répertoire gère le déploiement de **Nginx Proxy Manager** et du serveur web **Nginx**.

## Installation

**Réseau**
Le réseau `proxy` de type `bridge` permet de brancher NPM aux autres containers qui nécessitent d'êtres connectés à internet.

```bash
docker create network proxy
```

**Lancement**
Cela créera un dossier dans `/srv/docker/nginx-proxy-manager/`, il peut être modifié dans le `docker-compose`

```bash
docker compose up -d nginx-proxy-manager
```

**Sécurité**

```bash
sudo chmod 700 /srv/docker/nginx-proxy-manager
```

_Une documentation plus importante arrive_

### Utilisation de Nginx

Afin de servir les sites webs **statiques** et **PHP**, j'utilise un serveur Nginx qui sera au sein du réseau proxy.

| Type       | Emplacement Host       | Emplacement container |
| ---------- | ---------------------- | --------------------- |
| Sites webs | /var/www               | /usr/share            |
| Configs    | /devOps/web/nginx/conf | /etc/nginx/conf.d/    |

Dans ce dossier on stocke les configurations de Nginx avec des permissions `root`.

```bash
mkdir -p nginx/conf
chmod 700 nginx
```


