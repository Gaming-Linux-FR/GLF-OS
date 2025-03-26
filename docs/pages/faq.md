---
title: F.A.Q 
layout: default 
---

# F.A.Q 

## Qu’est-ce que GLF OS ?

GLF OS est le nom d’un des projets réalisés par la communauté Gaming Linux Fr.
Ce projet consiste à réaliser un système d’exploitation, autour d’un cahier des charges stricte et 100% réalisé par la communauté pour la communauté.

GLF OS est basé sur [NixOS](https://nixos.org/), avec une orientation gaming et multimédia.

Pour en savoir plus, je vous invite à visiter [cette page](https://www.gaminglinux.fr/?page_id=8365).

## Quelle est la configuration requise ?

Celle-ci est indiquée sur la [page suivante](./documentation/minimalConfiguration.html).

## GLF OS peut-il être installé avec le secureboot actif ? 

Actuellement non. C'est un objectif que nous souhaitons atteindre à l'avenir.

## Une installation sans connexion internet est-elle possible ? 

Non, nous utilisons une fonctionnalité de NixOS appelé *Flocon* qui a besoin d'internet pour fonctionner. 

## Je souhaite installer GLF OS sur mon PC, comment dois-je procéder ?

{: .info }
> Pré-requis : Avoir désactivé le secure boot et avoir une connexion internet active

Une fois les pré-requis validé, il suffit alors de créer une clé USB bootable. Plusieurs logiciels permettent la réalisation d’une clé USB Bootable. Dans les plus connus, on peut citer :

- Ventoy
- Rufus
- Balena Etcher
- Mint Stick (l’outil de Linux Mint)
- etc…

Cela dit, suite à quelques retours, nous vous conseillons l’utilisation de Balena Etcher pour éviter tout désagrément. Pour cela, vous pouvez consulter le tuto que nous avons réalisé et qui est disponible [ici](https://codeberg.org/Gaming-Linux-FR/usb-bootable).

## Quelle est la durée moyenne d'installation ?

{: .info }
> La durée d'installation fait référence au moment où vous avez cliqué sur **Installer**. 

La durée d'installation dépends de votre bande passante, avec la fibre et une machine moderne, comptez entre 8 et 12 minutes.

## Combien de données sont téléchargés pendant l'installation ? 

Nous fournissons dans l'iso l'ensemble des binaires compilés, de ce fait, la majorité des paquets n'ont pas besoin d'être téléchargés pendant l'installation. 

Notez cependant que le chargeur de démarrage (*grub*, *systemd-boot*) est téléchargé durant l'installation.

Ainsi, pour répondre à la question initial, nous avons observé un minimum de **500Mo** téléchargé durant l'installation.
La valeur peut croitre si les paquets fournis dans l'iso sont plus anciens que ceux disponibles en ligne.

## Le téléchargement est lent durant l'installation ! 

Les sources distribuant le cache de construction des paquets peut parfois être ralentis dans la journée dépendamment du traffic. 

## Mon installation reste bloqué à 46% ! 

En raison de la nature de Nix, l'installateur calamares ne reçoit pas d'informations sur l'avancée du téléchargement, compilation des paquets, etc. 
Ainsi, la barre de progression semble bloqué à 46% mais ne l'est pas.
Vous pouvez cliquer sur la petite loupe en bas à droite de l'installateur pour voir ce qu'il se passe. 

{: .info }
> Ce bug qui n'en est pas un n'est pas de notre ressors, il est aussi présent avec NixOS. 
> Nous n'avons pas l'intention de le corriger, la faible valeur ajoutée par rapport à l'énorme charge de travail impliqué ne vaut pas l'investissement.

## Je ne vois que GNOME comme choix d'environnement de bureau, avez-vous l'intention de supporter d'autres environnements ? 

Actuellement, nous prenons uniquement en charge GNOME. 
Nous souhaitons d'abord nous concentrer sur l'ajout d'améliorations à GLF-OS, ensuite nous ajouterons probablement KDE. 

## Puis-je passer GLF OS en "unstable" ? 

Actuellement, GLF OS suit nixos stable. Un version instable existe et propose des paquets plus récents.
Nous proposons uniquement des paquets stables et nous vous déconseillons d'utiliser unstable pour le moment. 

{: .info }
> A l'avenir, un de nos objectifs et de permettre l'installation de paquets unstable en conservant une base stable. 

## Comment mettre à jour GLF OS ?

Les mises à jour sont automatiques et vous n’avez pas besoin de vous en occuper, GLF OS le fait pour vous ! Il vous faudra juste redémarrer votre système de temps en temps pour que l'ensemble des mises à jour s'appliquent.

Il est également possible de vérifier et d'appliquer les mises à jour via les commandes suivantes :

- `glf-update` : Permet de mettre à jour les dépôts
- `glf-build` : Teste la mise à jour
- `glf-switch` : Applique la mise à jour

{: .info }
> Un redémarrage est conseillé pour l'application de l'ensemble des mises à jour et vérifier que tout fonctionne.











