{
  description = "GLF-OS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
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

        # Import brut de nixpkgs-unstable
        pkgs-unstable-import = import nixpkgs-unstable {
          inherit system;
          config = nixpkgsConfig;
        };
        # Jeu de paquets unstable pour ce système
       pkgs-unstable = pkgs-unstable-import;


        # Modules de base locaux (suppose que ./modules/default existe)
        baseModules = [
          ./modules/default
          { nixpkgs.config = nixpkgsConfig; }
        ];

        # Arguments spéciaux à passer aux modules
        specialArgs = {
          # Passer le jeu de paquets unstable
          inherit pkgs-unstable; # Raccourci pour pkgs-unstable = pkgs-unstable;
        };

        # Optionnel : définir nixosModules ici si vous préférez
        # nixosModulesDefinition = {
        #   default = ./modules/default;
        # };

      in
      { # Début des outputs du flake
        iso = self.nixosConfigurations."glf-installer".config.system.build.isoImage;

        nixosConfigurations = {
          "glf-installer" = nixpkgs.lib.nixosSystem {
            inherit system specialArgs;
            modules = baseModules ++ [
              "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-gnome.nix"
              "${nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
              ./iso-cfg/configuration.nix
              { # Overlay Calamares
                nixpkgs.overlays = [
                  (_self: super: {
                    calamares-nixos-extensions = super.calamares-nixos-extensions.overrideAttrs (_oldAttrs: {
                      postInstall = ''
                        cp ${./patches/calamares-nixos-extensions/modules/nixos/main.py}              $out/lib/calamares/modules/nixos/main.py
                        cp -r ${./patches/calamares-nixos-extensions/config/settings.conf}             $out/share/calamares/settings.conf
                        cp -r ${./patches/calamares-nixos-extensions/config/modules/packagechooser.conf} $out/share/calamares/modules/packagechooser.conf
                        cp -r ${./patches/calamares-nixos-extensions/branding/nixos/show.qml}         $out/share/calamares/branding/nixos/show.qml
                        cp -r ${./patches/calamares-nixos-extensions/branding/nixos/white.png}         $out/share/calamares/branding/nixos/white.png
                        cp -r ${./patches/calamares-nixos-extensions/branding/nixos/base.png}          $out/share/calamares/branding/nixos/base.png
                        cp -r ${./patches/calamares-nixos-extensions/branding/nixos/fast.png}          $out/share/calamares/branding/nixos/fast.png
                        cp -r ${./patches/calamares-nixos-extensions/branding/nixos/gaming.png}        $out/share/calamares/branding/nixos/gaming.png
                        cp -r ${./patches/calamares-nixos-extensions/branding/nixos/logo-glf-os.svg}   $out/share/calamares/branding/nixos/logo-glf-os.svg
                        cp -r ${./patches/calamares-nixos-extensions/branding/nixos/branding.desc}     $out/share/calamares/branding/nixos/branding.desc
                      '';
                    });
                  })
                ];
              }
              ( # Options de l'image ISO
                { config, ... }:
                {
                  isoImage = {
                    volumeID = "GLF-OS-BETA-OMNISLASH_stable";
                    includeSystemBuildDependencies = false;
                    storeContents = [ config.system.build.toplevel ];
                    squashfsCompression = "zstd -Xcompression-level 22";
                    contents = [
                      {
                        source = ./iso-cfg;
                        { source = ./modules; target = "/iso-modules"; }
                      }
                    ];
                  };
                }
              )
            ];
          };

          # Configuration pour un système utilisateur réel (exemple)
          # Vous devriez adapter ou supprimer cette partie selon vos besoins
          "GLF-OS" = nixpkgs.lib.nixosSystem {
            inherit system specialArgs;
            modules = baseModules ++ [
              # Exemple: inclure les fichiers locaux si ce flake est dans /etc/nixos
              # ./configuration.nix
              # ./hardware-configuration.nix
            ];
          };

          "user-test" = nixpkgs.lib.nixosSystem {
            inherit system specialArgs;
            modules = baseModules ++ [
              { # Paramètres spécifiques VM/test
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
        }; # Fin de nixosConfigurations

        # === AJOUT DE L'EXPORT DES MODULES NIXOS ===
        nixosModules = {
           # Expose le point d'entrée de vos modules locaux
           default = ./modules/default;
           # Vous pourriez aussi exporter des modules individuels ici si nécessaire
           # gaming = ./modules/default/gaming.nix;
        };
        # ==========================================

      } # Fin des outputs du flake
      // utils.lib.eachDefaultSystem ( # Début de la section devShells
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
              if [ -d "docs" ]; then
                cd docs || exit 1
                echo "Running bundle install and starting Jekyll server..."
                bundle config set path 'vendor/bundle' --local
                bundle install
                bundle exec jekyll serve
              else
                echo "Directory 'docs' not found. Skipping Jekyll setup."
              fi
            '';
          };
        }
      ); # Fin de la section devShells
}
