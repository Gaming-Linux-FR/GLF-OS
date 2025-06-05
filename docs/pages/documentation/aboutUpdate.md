---
title: À propos des mises à jours 
layout: default 
parent: Documentation
---

# A quelle fréquence apparaissent les mises à jours ?

GLF-OS ira chercher si de nouvelles mises à jour sont disponibles (glf-update) 5 minutes après le boot de votre PC, puis toutes les 12 heures si le PC reste allumé. Une fois cette recherche effectuée, si des nouveaux paquets sont disponibles, la mise à jour sera appliquée en tâche de fond et au prochain reboot vous serez sur une GLF-OS avec les dernières mises à jour.


## Comment mettre à jour manuellement ? 

Le flocon fournis à l'utilisateur gère en un seul point le suivi des paquets Nix (nixpkgs) et le suivi du module GLF. Le flocon cherche la dernière version disponible des paquets Nix et les modules GLF puis référence les informations de versions dans un fichier flake.lock.

Ce qui implique que tant que le fichier n'est pas mis à jour, `nixos-rebuild` reconstruit en pointant sur la même version.

Le fait de mettre à jour manuellement peut devenir utile dans le cas où vous auriez modifié le customConfig prévu pour installer vos propres paquets NixOS ou pour appliquer une configuration de votre choix.

## Mettre à jour le flocon 


```bash
glf-update 
```

Si vous voyez une ligne comme `Updated input "nixpkgs"` ou `Updated input "glf"`, çela signifie qu'un input pointe sur une nouvelle version plus récente alors la prochaine reconstruction effectuera une mise à jour.

## Mettre à jour le système

Maintenant que le flocon pointe sur la dernière version en date disponible, vous pouvez effectuer : 

```bash
glf-switch
```
Cela aura pour effet de télécharger les paquets mis à jour ou d'installer vos nouveaux paquets que vous avez déclaré dans le customConfig. Cette action sera appliquée desuite sans avoir besoin de reboot (hors changement de kernel)

