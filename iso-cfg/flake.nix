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
