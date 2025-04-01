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
            config.nixpkgs.unstable = import nixpkgs-unstable { # Fournir nixpkgs.unstable
              inherit system;
              config.allowUnfree = true;
            };
            environment.systemPackages = with config.nixpkgs.unstable.legacyPackages.${system}; [ # Utiliser config.nixpkgs.unstable
              heroic
              lutris
            ];
          }
        ];
      };
    };
}
