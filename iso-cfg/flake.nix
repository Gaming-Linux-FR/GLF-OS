# flake.nix (CORRIGÉ - Placer dans projet_racine/iso-cfg/flake.nix)
{
  description = "GLF-OS ISO Configuration - Installer Evaluation Flake";

  # Inputs minimums requis pour évaluer la config
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Plus besoin de glfRoot
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      self, # Ajouter self car on définit nixosConfigurations
      ...
    }:
    let
      system = "x86_64-linux";
      nixpkgsConfig = { allowUnfree = true; };

      # Import stable
      pkgs = import nixpkgs {
        inherit system;
        config = nixpkgsConfig;
      };

      # Import unstable et définition du jeu de paquets
      unstablePkgsImport = import nixpkgs-unstable {
        inherit system;
        config = nixpkgsConfig;
      };
      pkgs-unstable = unstablePkgsImport; # Correction legacyPackages

      # Modules de base locaux (seront copiés par main.py dans ./modules)
      baseModules = [
         # Référence le dossier ./modules qui existera dans /mnt/etc/nixos
         ./modules/default
         { nixpkgs.config = nixpkgsConfig; }
      ];

    in
    {
      # Configuration que Calamares installera
      nixosConfigurations."GLF-OS" = nixpkgs.lib.nixosSystem {
         inherit system pkgs; # Base stable

         # Passer unstable aux modules via specialArgs
         specialArgs = {
            inherit pkgs-unstable;
         };

         # Utilise les baseModules (locaux après copie) + config générée
         modules = baseModules ++ [
           ./configuration.nix # Généré par main.py, contient import hardware-config
         ];
      };
    };
}
