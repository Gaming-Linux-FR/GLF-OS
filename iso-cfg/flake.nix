# flake.nix (Celui utilisé par Calamares pour installer)
{
  description = "GLF-OS ISO Configuration";

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
      ...
    }:
    let
      system = "x86_64-linux";
      pkgsSettings =
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      unstablePkgsImport = 
        import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };

      # Définir la variable ici en utilisant l'argument 'glf'
      glfDefaultModules = glf.nixosModules.default;

      # Définir le jeu de paquets unstable pour l'utiliser ci-dessous
      # et potentiellement dans specialArgs
      pkgs-unstable = unstablePkgsImport.legacyPackages.${system};

    in
    {
      nixosConfigurations."GLF-OS" = nixpkgs.lib.nixosSystem {
        # Paquets de base venant de nixpkgs (stable 24.11)
        pkgs = pkgsSettings "x86_64-linux";

        # Argument spécial pour rendre pkgs-unstable dispo aux modules GLF
        # (si gaming.nix, etc., en ont besoin)
        specialArgs = {
           # Passer le jeu de paquets unstable
           inherit pkgs-unstable;
           
           # inherit glf; # Si les modules GLF ont besoin d'accéder à l'input glf
        };

        modules = [
          ./configuration.nix
          glfDefaultModules
          # {
          #   environment.systemPackages = with pkgs-unstable; [
          #     heroic
          #     lutris
          #   ];
          # }
        ];
      };
    };
}
