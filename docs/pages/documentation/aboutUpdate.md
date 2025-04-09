---
title: À propos des mises à jours 
layout: default 
parent: Documentation
---

# A quelle fréquence apparaissent les mises à jours ?

GLF-OS ira chercher si de nouvelles mise à jour sont dispobible (glf-update) 5 minutes après le boot de votre PC puis toutes les 12 heures si le pc reste allumé.
Une fois cette recherche effectuée , si de nouveaux paquets sont disponible ,la mise à jour sera appliquée en tâche de fond et au prochain reboot vous serez sur une GLF-OS avec les dernières update.

## Comment mettre à jour manuellement ? 

Actuellement, aucun outil graphique n'est disponible, il est donc nécessaire d'ouvrir l'application `console`. 

### Mettre à jour manuellement le module GLF 
Le flocon cherche la dernière version disponible des paquets nix et les modules GLF puis référence les informations de versions dans un fichier `flake.lock`.

```bash
sudo bash /etc/update-glf-config.sh
```
Le fait de mettre à jour manuellement peut devenir utile dans le cas où vous auriez modifié le customConifg prévu pour installé vos propres paquets nixos ou pour appliquer une config de votre choix.

### Mettre à jour manuellement les paquets

```bash
sudo nixos-rebuild switch --upgrade
```

## Mettre à jour le flocon 

{: .info }
> Les manipulations suivantes nécessite une élévation de privilèges et sont à effectués avec sudo. 

```bash
glf-update 
```



## Mettre à jour le système

Maintenant que le flocon pointe sur la dernière version en date disponible, vous pouvez effectuer : 

```bash
glf-switch
```

Cela aura pour effet de télecharger les paquets mis à jour ou d'installer vos nouveaux paquets que vous avez déclaré dans le customConfig. Cette action sera appliquée desuite sans avoir besoin de reboot (hors changement de kernel)

