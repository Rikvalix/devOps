# Agent Jenkins

Permet de lancer une pipeline dans un autre container et de ne pas utiliser le controleur en tant que runner mais en tant qu'orchestrateur.

## Unbound Agent

Communique avec le contrôleur Jenkins situé sur l'host.

## Android Agent

Utilisant l'image Unbound, ce runner est configuré avec Android version:`39` et Gradle 
