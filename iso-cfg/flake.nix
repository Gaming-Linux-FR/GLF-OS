# flake.nix (CORRIGÉ - Pour iso-cfg - Version "via GitHub")
{
  description = "GLF-OS ISO Configuration - Installer Evaluation Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Input pointant vers le dépôt EXTERNE qui contient les modules GLF
    # Assurez-vous que ce dépôt/branche exporte bien nixosModules.default !
    glf = { url = "github:vinceff/GLF-OS-stable/glf-os-stable"; follows = "nixpkgs"; };
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      glf, # Input externe GLF
      self,
      ...
    }:
    let
      system = "x86_64-linux";
      nixpkgsConfig = { allowUnfree = true; };

      pkgs = import nixpkgs { inherit system; config = nixpkgsConfig; };

      unstablePkgsImport = import nixpkgs-unstable { inherit system; config = nixpkgsConfig; };
      pkgs-unstable = unstablePkgsImport; # Correction legacyPackages

      # Récupère les modules depuis l'input EXTERNE 'glf' via 'let' pour éviter pb de scope
      # **REQUIERT** que le flake 'glf' exporte nixosModules.default
      glfDefaultModules = glf.nixosModules.default;

    in
    {
      nixosConfigurations."GLF-OS" = nixpkgs.lib.nixosSystem {
         inherit system pkgs; # Base stable

         # Passer pkgs-unstable aux modules venant de 'glf'
         specialArgs = {
            inherit pkgs-unstable;
            # On pourrait aussi passer 'glf' si les modules en ont besoin
            # inherit glf;
         };

         modules = [
           ./configuration.nix # Généré par Calamares
           glfDefaultModules   # Modules venant du dépôt GitHub externe
         ];
      };
    };
}
