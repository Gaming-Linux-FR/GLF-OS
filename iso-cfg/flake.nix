{
  description = "GLF-OS ISO Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    glf.url = "github:Gaming-Linux-FR/GLF-OS/main";
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
    in
    {
      nixosConfigurations."GLF-OS" = nixpkgs.lib.nixosSystem {
        pkgs = pkgsSettings "x86_64-linux";
        modules = [
          ./configuration.nix
          inputs.glf.nixosModules.default
          {
            environment.systemPackages = with (import nixpkgs-unstable { # Appel direct
              inherit system;
              config.allowUnfree = true;
            }).legacyPackages.${system}; [
              heroic
              lutris
            ];
          }
        ];
      };
    };
}
