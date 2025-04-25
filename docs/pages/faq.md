---
title: F.A.Q 
layout: default 
---

# F.A.Q 

## Qu’est-ce que GLF OS ?

GLF OS est le nom d’un des projets réalisés par la communauté Gaming Linux Fr.
Ce projet consiste à réaliser un système d’exploitation, autour d’un cahier des charges stricte et 100% réalisé par la communauté pour la communauté.

GLF OS est basé sur [NixOS](https://nixos.org/), avec une orientation gaming et multimédia.

Pour en savoir plus, visitez [cette page](https://www.gaminglinux.fr/?page_id=8365).

## Quelle est la configuration requise ?

Celle-ci est indiquée sur la [page suivante](./documentation/minimalConfiguration.html).

## GLF OS peut-il être installé avec le secureboot actif ? 

Non. Pour le moment, il vous faut le désactiver sur votre ordinateur.

## Une installation sans connexion internet est-elle possible ? 

Non, nous utilisons une fonctionnalité de NixOS appelé *Flocon* qui a besoin d'internet pour fonctionner. 

## Je souhaite installer GLF OS sur mon PC, comment dois-je procéder ?

{: .info }
> Pré-requis : Avoir désactivé le secure boot et avoir une connexion internet active

Une fois les pré-requis validés, il suffit alors de créer une clé USB bootable. Plusieurs logiciels permettent la réalisation d’une clé USB Bootable. Dans les plus connus, on peut citer :

- Ventoy
- Rufus
- Balena Etcher
- Mint Stick (l’outil de Linux Mint)
- etc…

Cela dit, suite à quelques retours, nous vous conseillons l’utilisation de Balena Etcher pour éviter tout désagrément. Pour cela, vous pouvez consulter le tuto que nous avons réalisé et qui est disponible [ici](https://codeberg.org/Gaming-Linux-FR/usb-bootable).

## Quelle est la durée moyenne de l'installation ?

{: .info }
> La durée d'installation fait référence au moment où vous avez cliqué sur **Installer**. 

La durée d'installation dépend de votre bande passante. A titre d'exemple, avec la fibre et une machine récente, comptez entre 8 et 12 minutes.

## Combien de données sont téléchargées pendant l'installation ? 

Nous fournissons dans l'ISO l'ensemble des binaires compilés. De ce fait, la majorité des paquets n'ont pas besoin d'être téléchargés pendant l'installation. 

Notez cependant que le chargeur de démarrage (*grub*) est téléchargé durant l'installation.

Nous avons observé un minimum de **500Mo** téléchargés durant l'installation.

## Le téléchargement est lent durant l'installation ! 

Les sources distribuant le cache de construction des paquets peuvent parfois être ralenties dans la journée en fonction du traffic. 

## Mon installation reste bloquée à 46% ! 

En raison de la nature de Nix, l'installateur calamares ne reçoit pas d'information sur l'avancée du téléchargement, compilation des paquets, etc. 
Ainsi, la barre de progression semble bloquée à 46% mais ne l'est pas.
Vous pouvez cliquer sur la petite loupe en bas à droite de l'installateur pour voir ce qu'il se passe. 

{: .info }
> Ce problème d'affichage n'est pas directement de notre ressors, il est aussi présent avec NixOS. 
> Nous n'avons pas l'intention de le corriger, la faible valeur ajoutée par rapport à l'énorme charge de travail impliquée ne vaut pas l'investissement.

## Je ne vois que GNOME comme choix d'environnement de bureau, avez-vous l'intention de supporter d'autres environnements ? 

Actuellement, nous prenons uniquement en charge GNOME. 
L'ajout de KDE est prévu pour la version Beta.

## Puis-je passer GLF OS en "unstable" ? 

GLF OS est proposée en deux versions :

- **GLF OS Stable** : La version optimale de GLF OS, un mix parfait entre paquets frais et stabilité. Nous exploitons toutes les possibilités de NixOS pour vous fournir un système fiable au quotidien. Profitez du meilleur des deux mondes : les paquets gaming reçoivent les toutes dernières nouveautés, tandis que le reste du système évolue par étapes majeures tous les six mois (à l’image de Fedora), garantissant ainsi une base solide et testée.
- **GLF OS Rolling** : L’expérience à la pointe (bleeding edge) par excellence ! Cette version est constamment mise à jour, idéale pour tester les fonctionnalités les plus récentes et assurer la compatibilité avec le matériel neuf. C’est un choix pour les utilisateurs avertis, conscients que des bugs ou des « rebuilds » problématiques peuvent survenir temporairement.

Si vous avez déjà installé la version stable, vous pouvez passer sur la version unstable en [A compléter].

## Comment mettre à jour GLF OS ?

Les mises à jour sont automatiques et vous n’avez pas besoin de vous en occuper, GLF OS le fait pour vous ! Il vous faudra juste redémarrer votre système de temps en temps pour que l'ensemble des mises à jour s'appliquent.

Il est également possible de vérifier et d'appliquer les mises à jour via les commandes suivantes :

- `glf-update` : Permet de mettre à jour les dépôts
- `glf-build` : Teste la mise à jour
- `glf-switch` : Applique la mise à jour

{: .info }
> Un redémarrage est conseillé pour l'application de l'ensemble des mises à jour et vérifier que tout fonctionne.

## Comment retirer les informations affichées en haut de l'écran lorsqu'on lance un jeu ?

Il suffit d'utiliser le raccourci clavier `MAJ droite + F12`.
Ces informations proviennent de Mangohud et un outil devrait arriver avec la version Beta pour pouvoir gérer cela.

## J’ai un problème avec GLF OS, que faire ?

Le mieux est de nous en faire part pour que l’on puisse vous aider à le résoudre ou à identifier un bug à faire corriger. Pour cela, vous pouvez nous en faire part sur Discord ou sur le Github dont les liens sont disponibles [ici](https://www.gaminglinux.fr/?page_id=8365#brxe-dd7c57).

## Je souhaite soumettre une amélioration, comment faire ?

Pour cela, vous pouvez nous en faire part sur Discord ou sur le Github dont les liens sont disponibles [ici](https://www.gaminglinux.fr/?page_id=8365#brxe-dd7c57).

## Où trouver les informations sur les dernières nouveautés ?

Toutes nos notes de version sont disponibles [ici](https://www.gaminglinux.fr/tag/glfos-version/) et c’est dans celles-ci que seront annoncées les nouveautés.

A noter que vous retrouverez également les release notes, directement sur le Github du projet [ici](https://github.com/Gaming-Linux-FR/GLF-OS/releases).
