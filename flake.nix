{
  description = "GLF-OS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      utils,
      ...
    }:
    let
      system = "x86_64-linux";
      nixpkgsConfig = {
        allowUnfree = true;
      };
      nixosModules = {
        default = import ./modules/default;
      };

      baseModules = [
        nixosModules.default
        { nixpkgs.config = nixpkgsConfig; }
      ];

    in
    {
      iso = self.nixosConfigurations."glf-installer".config.system.build.isoImage;

      nixosConfigurations = {
        # Configuration pour l'ISO d'installation avec Calamares
        "glf-installer" = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = baseModules ++ [
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-gnome.nix"
            "${nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
            ./iso-cfg/configuration.nix
            {
              nixpkgs.overlays = [
                (_self: super: {
                  calamares-nixos-extensions = super.calamares-nixos-extensions.overrideAttrs (_oldAttrs: {
                    postInstall = ''
                      cp ${./patches/calamares-nixos-extensions/modules/nixos/main.py}                   $out/lib/calamares/modules/nixos/main.py
                      cp ${./patches/calamares-nixos-extensions/config/settings.conf}                    $out/share/calamares/settings.conf
                      cp ${./patches/calamares-nixos-extensions/config/modules/environment.conf}         $out/share/calamares/modules/environment.conf
                      cp ${./patches/calamares-nixos-extensions/config/modules/edition.conf}             $out/share/calamares/modules/edition.conf
                      cp ${./patches/calamares-nixos-extensions/branding/nixos/show.qml}                 $out/share/calamares/branding/nixos/show.qml
                      cp ${./patches/calamares-nixos-extensions/branding/nixos/white.png}                $out/share/calamares/branding/nixos/white.png
                      cp ${./patches/calamares-nixos-extensions/branding/nixos/base.png}                 $out/share/calamares/branding/nixos/base.png
                      cp ${./patches/calamares-nixos-extensions/branding/nixos/fast.png}                 $out/share/calamares/branding/nixos/fast.png
                      cp ${./patches/calamares-nixos-extensions/branding/nixos/gaming.png}               $out/share/calamares/branding/nixos/gaming.png
                      cp ${./patches/calamares-nixos-extensions/branding/nixos/logo-glf-os.svg}          $out/share/calamares/branding/nixos/logo-glf-os.svg
                      cp ${./patches/calamares-nixos-extensions/branding/nixos/branding.desc}            $out/share/calamares/branding/nixos/branding.desc
                    '';
                  });
                })
              ];
            }
            (
              { config, ... }:
              {
                isoImage = {
                  volumeID = "GLF-OS-ALPHA-OMNISLASH_2"; #Nom à changer en fonction de la nomination GLF OS
                  includeSystemBuildDependencies = false;
                  storeContents = [ config.system.build.toplevel ];
                  squashfsCompression = "zstd -Xcompression-level 22";
                  contents = [
                    {
                      source = ./iso-cfg;
                      target = "/iso-cfg";
                    }
                  ];
                };
              }
            )
          ];
        };

        # Configuration de test utilisateur simulée
        "user-test" = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = baseModules ++ [
            {
              boot.loader.grub = {
                enable = true;
                device = "/dev/sda";
                useOSProber = true;
              };

              fileSystems."/" = {
                device = "/dev/sda1";
                fsType = "ext4";
              };
            }
          ];
        };
      };

      inherit nixosModules;
    }
    // utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = nixpkgsConfig;
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.ruby
            pkgs.bundler
          ];
          shellHook = ''
            cd docs || exit 1
            echo "Running bundle install and starting Jekyll server..."
            bundle config set path 'vendor/bundle'
            bundle install
            bundle exec jekyll serve
          '';
        };
      }
    );
}
