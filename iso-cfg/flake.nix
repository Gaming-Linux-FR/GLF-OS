# flake.nix iso-cfg
{
  description = "GLF-OS ISO Configuration - Installer Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # 'follows' assure la cohérence de nixpkgs.
    glfRoot = { url = "path:../"; follows = "nixpkgs"; };
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      glfRoot, 
     
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
   
      pkgs-unstable = unstablePkgsImport;

     # --- Débogage ---
      # On essaie d'accéder à nixosModules SANS le .default d'abord
      glfModulesTemp = glfRoot.nixosModules or null; # Utilise 'or null' pour éviter une erreur si nixosModules manque
      # On affiche ce qu'on a trouvé (ou null)
      _ = builtins.trace "TRACE iso-cfg: Contenu de glfRoot.nixosModules: ${builtins.toJSON glfModulesTemp}" null;
      # On tente ensuite d'accéder à .default SEULEMENT si glfModulesTemp n'est pas null
      glfDefaultModules = if glfModulesTemp == null then {} else glfModulesTemp.default;
      # --- Fin Débogage ---

    in
    {
      # Définit la configuration NixOS que Calamares doit installer
      nixosConfigurations."GLF-OS" = nixpkgs.lib.nixosSystem {
        inherit pkgs; # Paquets de base venant de nixpkgs (stable 24.11)

        # Arguments spéciaux pour les modules (venant du flake racine)
        specialArgs = {
           inherit pkgs-unstable; # Passer le jeu de paquets unstable correctement défini
        };

        modules = [
          # Configuration locale générée par Calamares sur la cible
          ./configuration.nix
          # Important: Le configuration.nix généré par main.py importe déjà hardware-configuration.nix

          # Modules GLF venant du flake racine (qui gère pkgs-unstable via specialArgs)
          glfDefaultModules
        ];
      };
    };
}
