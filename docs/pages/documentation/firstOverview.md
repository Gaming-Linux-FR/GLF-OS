---
title: Premier tour d'horizon
layout: default
parent: Documentation
nav_order: 2
---

{: .in-progress }
> En cours d'écriture.

{: .todo }
> A reformuler et illustrer, les principales idées ont été notées.

# Premier tour d'horizon de GLF-OS

Après vous êtres connecté à votre session, vous remarquerez que GNOME est pré-configuré. 

Nous vous proposons des extensions comme `GSConnect` pour vous connecter à votre smartphone, `Caféine` pour désactiver le `screensaver` et la suspension automatique (pratique pour éviter la mise en veille durant vos sessions gamings). 

L'extension `Dash-to-Dock` est également de la partie, les principaux launcher de jeux sont déjà épinglés !

Côté applications, nous vous proposons les applications de base pour répondre aux usages liés à la bureautique !

Les imprimantes sont pris en charge, vous n'avez qu'à l'ajouter à GNOME ! 

{: .note }
> Les principaux pilotes sont présents pour répondre à un large panel de matériel. 
> Si votre imprimante n'est pas pris en charge, faites-le nous savoir en ouvrant une issue sur github ou via discord. 

Vivaldi est disponible si vous souhaitez jouer aux jeux en streaming.

Si GLF-OS ne vous satisfait pas complètement, nous vous avons laissé à disposition `Easy Flatpak` qui est un magasin d'applications pour Flatpak. 

## Les commandes de base 

Pour faciliter les quelques intéractions que vous pourriez avoir avec le terminal, nous avons ajoutés des commandes `glf`. 

{: .info }
> Ces nouvelles commandes sont des alias vers des commandes NixOS plus verbeuse.
> Notez que ces alias fonctionnent uniquement si vous avez la fonctionnalité expérimental `flake` d'activé, ce qui est le cas par défaut avec GLF-OS.

| Nom             | Fonction                                                         | Alias de _                                                                                                           |
|------------------|------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------|
| `glf-update`    | Mise à jour du flocon (cherche les dernières versions du module GLF et Nixpkgs, ne concerne pas la mise à jour des flatpaks) | `sudo nix flake update --flake /etc/nixos`                                                                          |
| `glf-build`     | Construction de la génération (sans l'appliquer)                | `nh os build /etc/nixos -H GLF-OS`                                                                                  |
| `glf-switch`    | Construction et application de la génération (appliqué maintenant) | `nh os switch /etc/nixos -H GLF-OS`                                                                                 |
| `glf-boot`      | Construction et application de la génération (appliqué au prochain démarrage) | `nh os boot /etc/nixos -H GLF-OS`                                                                                   |
| `glf-systeminfo`| Permet de récupérer des informations préliminaires sur l'appareil lors de dépannage | ```bash echo -e "\n--- Infos ---"; \ inxi -M; \ echo -e "\n--- CPU ---"; \ lscpu | grep -E "(Architecture|CPU op-mode|Vendor ID|Model name|Mode\(s\) opératoire\(s\) des processeurs|Identifiant constructeur|Nom de modèle)" | awk "{print \$0}"; \ echo -e "\n--- GPU ---"; \ lspci | grep -E "VGA|3D"; \ echo -e "\n--- Disque ---"; \ df -h; \ echo -e "\n--- RAM ---"; \ free -h``` |







