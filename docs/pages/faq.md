---
title: F.A.Q 
layout: default 
---

# F.A.Q 

## Qu’est-ce que GLF OS ?

GLF OS est le nom d’un des projets les plus fous réalisés par la communauté Gaming Linux Fr.
Ce projet consiste à réaliser un système d’exploitation, autour d’un cahier des charges stricte et 100% réalisé par la communauté pour la communauté.

{: .info }
> Notez que secureboot doit être désactivé pour que GLF-OS fonctionne. 

## Comptez-vous proposer une installation entièrement hors-ligne ? 

Non, nous utilisons une fonctionnalité de NixOS appelé *Flocon* qui a besoin d'internet pour fonctionner. 

## Je souhaite installer GLF OS sur mon PC, comment dois-je procéder ?

Toutes les étapes pour installer GLF OS sont décrites [ici](https://gaming-linux-fr.github.io/GLF-OS/pages/documentation/Installation.html).

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

## Je ne vois que GNOME et KDE comme choix d'environnement de bureau, avez-vous l'intention de supporter d'autres environnements ? 

A ce stable, il n'est pas prévu l'ajout d'autres environnements de bureau.

## Je viens d'installer GLF OS et la logithèque n'est pas présente. Que faire ?

La logithèque que nous proposons est Easy Flatpak et elle est fournie en flatpak. Son installation a lieu après l'installation du système et elle peut mettre plusieurs dizaines de minutes à remonter en fonction de votre connexion.

## Puis-je passer GLF OS en "unstable" ? 

GLF OS est proposée en deux versions :

- **GLF OS Stable** : La version optimale de GLF OS, un mix parfait entre paquets frais et stabilité. Nous exploitons toutes les possibilités de NixOS pour vous fournir un système fiable au quotidien. Profitez du meilleur des deux mondes : les paquets gaming reçoivent les toutes dernières nouveautés, tandis que le reste du système évolue par étapes majeures tous les six mois (à l’image de Fedora), garantissant ainsi une base solide et testée.
- **GLF OS Rolling** : L’expérience à la pointe (bleeding edge) par excellence ! Cette version est constamment mise à jour, idéale pour tester les fonctionnalités les plus récentes et assurer la compatibilité avec le matériel neuf. C’est un choix pour les utilisateurs avertis, conscients que des bugs ou des « rebuilds » problématiques peuvent survenir temporairement.

Si vous avez déjà installé la version stable, vous pouvez passer sur la version unstable en suivant les étapes suivantes :

1. Aller dans /etc/nixos
2. Editer le fichier flake.nix pour supprimer le contenu et le remplacer par ce qui suit :

```
# flake.nix (CORRIGÉ - Pour iso-cfg - Version "via GitHub" - Révisé)
{
  description = "GLF-OS ISO Configuration - Installer Evaluation Flake";

  inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
        glf.url = "github:Gaming-Linux-FR/GLF-OS/rolling";
        nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
};

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      glf,
      self,
      ...
    }: 

    let
      system = "x86_64-linux"; 

      # Configuration pour le nixpkgs stable (sera le 'pkgs' par défaut)
      pkgsStable = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      # Configuration pour le nixpkgs unstable (sera passé en argument spécial)
      pkgsUnstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations."GLF-OS" = nixpkgs.lib.nixosSystem {
        inherit system; # Maintenant 'system' est défini
        pkgs = pkgsStable; 
        modules = [
          ./configuration.nix 
          glf.nixosModules.default 
        ];

        specialArgs = {
          pkgs-unstable = pkgsUnstable; 
        };
      };
    };
}
```

{: .info }
> Nous ne conseillons cette manipulation uniquement pour les personnes voulant faire des tests ou dans le cas de matériel hyper récent et non pris en charge en version stable.

## Comment mon système se met à jour ? 

Les mises à jour sont automatiques, un petit programme se lance dans les 5 minutes suivant le démarrage de votre ordinateur. Si une mise à jour est à appliquer, une notification apparaitra. Il vous faudra redémarrer votre système pour l'appliquer.

Il est également possible de vérifier et d'appliquer manuellement les mises à jour via les commandes suivantes :

- `glf-update` : Permet de mettre à jour les dépôts
- `glf-build` : Teste la mise à jour
- `glf-boot` : Applique la mise à jour

{: .info }
> Un redémarrage régulier est conseillé pour l'application de l'ensemble des mises à jour.

## Comment afficher / retirer les informations affichées en haut de l'écran lorsqu'on lance un jeu ?

Un outil graphique nommé Mangohud Presets est mis à votre disposition pour cela.

## J’ai un problème avec GLF OS, que faire ?

Le mieux est de nous en faire part pour que l’on puisse vous aider à le résoudre ou à identifier un bug à faire corriger. Pour cela, vous pouvez nous en faire part sur Discord ou sur le Github dont les liens sont disponibles [ici](https://www.gaminglinux.fr/?page_id=8365#brxe-dd7c57).

## Je souhaite soumettre une amélioration, comment faire ?

Pour cela, vous pouvez nous en faire part sur Discord ou sur le Github dont les liens sont disponibles [ici](https://www.gaminglinux.fr/?page_id=8365#brxe-dd7c57).

## Où trouver les informations sur les dernières nouveautés ?

Toutes nos notes de version sont disponibles [ici](https://www.gaminglinux.fr/tag/glfos-version/) et c’est dans celles-ci que seront annoncées les nouveautés.

