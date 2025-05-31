# flake.nix (Version "dev" corrigée avec specialArgs)
{
  description = "GLF-OS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; # Base stable
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      utils,
      ...
    }:
    let
      system = "x86_64-linux";

      nixpkgsConfig = {
        allowUnfree = true;
      };

      # Utilisation de nixpkgsConfig pour la cohérence
      pkgsStable = import nixpkgs {
        inherit system;
        config = nixpkgsConfig; 
      };

      pkgsUnstable = import nixpkgs-unstable {
        inherit system;
        config = nixpkgsConfig; 
      };


      nixosModules = {
        default = import ./modules/default;
      };

      baseModules = [
        nixosModules.default
        { nixpkgs.config = nixpkgsConfig; } # Passe la config aux modules
      ];


      specialArgs = {
        # Rend pkgsUnstable disponible pour les modules
        pkgs-unstable = pkgsUnstable;
      };

    in
    {
      iso = self.nixosConfigurations."glf-installer".config.system.build.isoImage;

    nixosConfigurations = {
        # Configuration pour l'ISO d'installation avec Calamares
        "glf-installer" = nixpkgs.lib.nixosSystem {
          # <<<=== AJOUT DE 'inherit specialArgs' ===>>>
          inherit system specialArgs; # Passe les arguments spéciaux aux modules
          modules = baseModules ++ [
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-gnome.nix"
            "${nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
            ./iso-cfg/configuration.nix
            { # Overlay Calamares
              nixpkgs.overlays = [
                (_self: super: {
                  calamares-nixos-extensions = super.calamares-nixos-extensions.overrideAttrs (_oldAttrs: {
                    postInstall = ''
                      cp ${./patches/calamares-nixos-extensions/modules/nixos/main.py}               $out/lib/calamares/modules/nixos/main.py
                      cp -r ${./patches/calamares-nixos-extensions/config/settings.conf}             $out/share/calamares/settings.conf
                      cp -r ${./patches/calamares-nixos-extensions/config/modules/edition.conf}      $out/share/calamares/modules/edition.conf
                      cp -r ${./patches/calamares-nixos-extensions/config/modules/environment.conf}  $out/share/calamares/modules/environment.conf
                      cp -r ${./patches/calamares-nixos-extensions/branding/nixos/show.qml}          $out/share/calamares/branding/nixos/show.qml
                      cp -r ${./patches/calamares-nixos-extensions/branding/nixos/white.png}         $out/share/calamares/branding/nixos/white.png
                      cp -r ${./patches/calamares-nixos-extensions/branding/nixos/base.png}          $out/share/calamares/branding/nixos/base.png
                      cp -r ${./patches/calamares-nixos-extensions/branding/nixos/fast.png}          $out/share/calamares/branding/nixos/fast.png
                      cp -r ${./patches/calamares-nixos-extensions/branding/nixos/gaming.png}        $out/share/calamares/branding/nixos/gaming.png
                      cp -r ${./patches/calamares-nixos-extensions/branding/nixos/logo-glf-os.svg}   $out/share/calamares/branding/nixos/logo-glf-os.svg
                      cp -r ${./patches/calamares-nixos-extensions/branding/nixos/branding.desc}     $out/share/calamares/branding/nixos/branding.desc
                      cp -r ${./patches/calamares-nixos-extensions/config/images/mini.png}           $out/share/calamares/images/mini.png
                      cp -r ${./patches/calamares-nixos-extensions/config/images/standard.png}       $out/share/calamares/images/standard.png
                      cp -r ${./patches/calamares-nixos-extensions/config/images/studio.png}         $out/share/calamares/images/studio.png
                      cp -r ${./patches/calamares-nixos-extensions/config/images/studio-pro.png}     $out/share/calamares/images/studio-pro.png
                    '';
                  });
                })
              ];
            }
            ( # Options ISO
              { config, ... }:
              {
                isoImage = {
                  volumeID = "GLF-OS-BETA-OMNISLASH";
                  includeSystemBuildDependencies = false;
                  storeContents = [ config.system.build.toplevel ];
                  squashfsCompression = "zstd -Xcompression-level 22";
                  efiSplashImage = ./assets/boot/glf-efi.png;
                  contents = [
                    { source = ./iso-cfg; target = "/iso-cfg"; }
                  ];
                };
              }
            )
          ];
        }; # Fin glf-installer

        # Configuration de test utilisateur simulée
        "user-test" = nixpkgs.lib.nixosSystem {
          inherit system specialArgs; # Passe les arguments spéciaux ici aussi
          modules = baseModules ++ [
            { # Config VM/test
              boot.loader.grub = { enable = true; device = "/dev/sda"; useOSProber = true; };
              fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };
            }
          ];
        }; # Fin user-test
      }; # Fin nixosConfigurations

      # Exporte les modules définis dans le 'let'
      inherit nixosModules;

    } # Fin des outputs principaux
    // utils.lib.eachDefaultSystem ( # Début devShell
      system:
      let
        # pkgs ici utilise l'input nixpkgs (stable) par défaut
        pkgs = import nixpkgs {
          inherit system;
          config = nixpkgsConfig;
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [ pkgs.ruby pkgs.bundler ];
          shellHook = ''
            if [ -d "docs" ]; then
              cd docs || exit 1
              echo "Running bundle install and starting Jekyll server..."
              bundle config set path 'vendor/bundle' --local # Utiliser --local
              bundle install
              bundle exec jekyll serve
            else
              echo "Directory 'docs' not found. Skipping Jekyll setup."
            fi
          '';
        };
      }
    ); # Fin devShell
}
