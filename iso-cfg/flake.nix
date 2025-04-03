# flake.nix (CORRIGÉ - Pour iso-cfg - Version "via GitHub")
{
  description = "GLF-OS ISO Configuration - Installer Evaluation Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    glf.url = "github:vinceff/GLF-OS-stable/glf-os-stable";
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      glf, 
      self,
      ...
    }@inputs:

    let
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
        inherit system; 
        pkgs = pkgsStable; 
        modules = [
          ./configuration.nix       
          glf.nixosModules.default.gaming  # Les modules de GLF qui nécessitent pkgs-unstable
        ];

        # C'est ici que la magie opère :
        specialArgs = {
          pkgs-unstable = pkgsUnstable; 
        };
      };
    };
}
