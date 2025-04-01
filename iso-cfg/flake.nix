{

  description = "GLF-OS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24_11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    glf.url = "github:Gaming-Linux-FR/GLF-OS/main";
  };

  outputs =
    { nixpkgs, nixpkgs-unstable, glf, ... }@inputs:
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
        {
            environment.systemPackages = with nixpkgs-unstable.legacyPackages.${system}; [
              nixpkgs-unstable.legacyPackages.${system}.heroic
              nixpkgs-unstable.legacyPackages.${system}.lutris
            ];
          }
        ];
      };
    };
}
