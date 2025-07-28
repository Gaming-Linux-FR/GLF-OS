{
  description = "GLF OS Welcome Screen using Flutter 3.2.7";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            # Overlay to expose flutter327
            (final: prev: {
              flutter327 = prev.callPackage "${nixpkgs}/pkgs/development/compilers/flutter/versions/flutter_3_2_7" {};
            })
          ];
        };

        flutter327 = pkgs.flutter327;
      in {
        packages.default = flutter327.buildFlutterApplication {
          pname = "glfos-welcome-screen";
          version = "1.0.11";
           # Fetch your project source
        src = pkgs.fetchFromGitHub {
          owner = "imikado";
          repo = "glfos-welcome-screen";
          rev = "1.0.12";
          sha256 = "0piqdp1rswv6b4bqfp7475kd5z96kvx5kwhiqdjgh4r0q4xzn30a"; # Get via nix-prefetch-url or nix build error
        };

          flutterBuildArgs = [ "linux" ];

          nativeBuildInputs = with pkgs; [
            pkg-config
            libadwaita
            glib
            gtk3
          ];

          meta = with pkgs.lib; {
            description = "GLF OS Welcome screen built with Flutter 3.2.7";
            homepage = "https://github.com/imikado/glfos-welcome-screen";
            license = licenses.mit;
            platforms = platforms.linux;
          };
        };
      });
}
