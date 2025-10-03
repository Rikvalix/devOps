# Docker registry

Le registry permet de stocker des images en local sur la machine, cela va nous permettre de stocker nos images customs, les images qui sont pull très souvents. C'est un gain de temps car on télécharge une fois l'image hébergé chez docker.

## Configuration

- Ecrite dans le `docker-compose.yml` à la racine du répertoire `ci-cd`
- Le fichier de configuration `yml` est situé dans le répertoire `registry`

## Commandes

### Lister

Voir la liste des images disponibles
```bash
curl http://localhost:5050/v2/_catalog
```

Liste les tags d'une image
```bash
curl http://localhost:5050/v2/<img>/tags/list
```

### Push / Pull

Tagger l'image
```bash
docker tag <image> localhost:5050/<image>:<tag>
```

Pousser une image
```bash
docker push localhost:5050/<image>:<tag>
```
--- 

Pull
```bash
docker pull localhost:5050/<image>:<tag>
```

## Notifications

Registry supporte l'envoi de notification via un webhook, [Documentation](https://distribution.github.io/distribution/about/notifications/)

# Ressources
- [Documentation officielle](https://distribution.github.io/distribution/)

