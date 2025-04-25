---
title: F.A.Q 
layout: default 
---

# F.A.Q 

## GLF-OS prends-t'il en charge le secureboot ? 

Non pas actuellement, c'est un objectif que nous souhaitons atteindre à l'avenir. 


{: .info }
> Notez d'ailleurs que secureboot doit être désactivé pour que GLF-OS fonctionne. 










## Comptez-vous proposer une installation entièrement hors-ligne ? 

Non, nous utilisons une fonctionnalité de NixOS appelé *Flocon* qui a besoin d'internet pour fonctionner. 

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

## Puis-je passer GLF-OS en "unstable" ? 

Actuellement, GLF-OS suit nixos stable. Un version instable existe et propose des paquets plus récents.
Nous proposons uniquement des paquets stables et nous vous déconseillons d'utiliser unstable pour le moment. 

{: .info }
> A l'avenir, un de nos objectifs et de permettre l'installation de paquets unstable en conservant une base stable. 



## Faut-il redémarrer après une mise à jour ? 

Il y a deux réponses à la question dépendamment de si le noyau linux a été mis à jour ou non. 

Dans le premier cas, le noyau a été mis à jour, il est préférable de redémarrer pour exécuter le nouveau noyau.

Dans le second cas, le noyau n'a pas été mis à jour, vous pouvez continuer à utiliser votre système sans redémarrer. 



{: .info }
> Dans les deux cas, vous souhaiterez redémarrer ne serait-ce que pour confirmer que la nouvelle version n'implémente pas de problèmes.























