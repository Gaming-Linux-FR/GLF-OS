# flake.nix (Dans iso-cfg/, corrigé pour utiliser les modules du flake racine)
{
  description = "GLF-OS ISO Configuration - Installer Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Input pointant vers le flake racine (situé dans le dossier parent ../)
    # 'follows' assure la cohérence de nixpkgs entre les deux flakes.
    # Vérifiez que le chemin "path:../" est correct !
    glfRoot = { url = "path:../"; follows = "nixpkgs"; };
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      glfRoot, # Nouvel input pour accéder au flake racine
      # self, # Ajouter si besoin
      ...
    }:
    let
      system = "x86_64-linux";
      nixpkgsConfig = { allowUnfree = true; };

      # Import stable pour la base pkgs
      pkgs = import nixpkgs {
        inherit system;
        config = nixpkgsConfig;
      };

      # Import unstable pour pkgs-unstable
      unstablePkgsImport = import nixpkgs-unstable {
        inherit system;
        config = nixpkgsConfig;
      };
      # *** CORRECTION legacyPackages ICI ***
      pkgs-unstable = unstablePkgsImport; # Le résultat de l'import est déjà le bon set

      # *** CORRECTION Module Import ICI ***
      # Récupère les modules depuis la sortie 'nixosModules.default' du flake racine
      # (le flake racine doit exporter nixosModules = { default = ./modules/default; };)
      glfDefaultModules = glfRoot.nixosModules.default;

    in
    {
      # Définit la configuration NixOS que Calamares doit installer
      nixosConfigurations."GLF-OS" = nixpkgs.lib.nixosSystem {
        # Paquets de base venant de nixpkgs (stable 24.11)
        inherit pkgs;

        # Arguments spéciaux à passer aux modules (venant du flake racine)
        specialArgs = {
           # Passer le jeu de paquets unstable correctement défini
           inherit pkgs-unstable;
           # On pourrait aussi passer l'input racine si les modules en ont besoin
           # inherit glfRoot;
        };

        modules = [
          # Configuration locale générée par Calamares sur la cible
          # (Ce fichier contient les choix de l'utilisateur : partitionnement, user, etc)
          ./configuration.nix

          # Modules GLF venant du flake racine (qui gère pkgs-unstable via specialArgs)
          glfDefaultModules
        ];
      };
    };
}
