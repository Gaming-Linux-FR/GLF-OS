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
    }:

    let
      pkgsSettings =
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
    in
    {
      nixosConfigurations."GLF-OS" = nixpkgs.lib.nixosSystem {
        pkgs = pkgsSettings "x86_64-linux";
        modules = [
          ./configuration.nix
          inputs.glf.nixosModules.default
        ];
      };
    };

}
