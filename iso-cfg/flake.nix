{

  description = "GLF-OS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    glf.url = "github:sebanc/GLF-OS-sebanc/dev";
  };

  outputs =
    { nixpkgs, glf, ... }@inputs:
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
