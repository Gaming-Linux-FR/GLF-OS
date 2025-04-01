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
    
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config = nixpkgsConfig;
      };

      baseModules = [
        ./modules/default
        { nixpkgs.config = nixpkgsConfig; }
      ];

      specialArgs = {
        pkgs-unstable = pkgs-unstable; 
      };

    in
    {
      iso = self.nixosConfigurations."glf-installer".config.system.build.isoImage;

      nixosConfigurations = {
        "glf-installer" = nixpkgs.lib.nixosSystem {
          inherit system specialArgs; # <<< Passer specialArgs ici
          modules = baseModules ++ [
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-gnome.nix"
            "${nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
            ./iso-cfg/configuration.nix
            {
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
                      # Assurez-vous que ce chemin est correct : ./patches/calamares-extensions/... ou ./patches/calamares-nixos-extensions/... ?
                      cp -r ${./patches/calamares-nixos-extensions/branding/nixos/gaming.png}        $out/share/calamares/branding/nixos/gaming.png
                      cp -r ${./patches/calamares-nixos-extensions/branding/nixos/logo-glf-os.svg}   $out/share/calamares/branding/nixos/logo-glf-os.svg
                      cp -r ${./patches/calamares-nixos-extensions/branding/nixos/branding.desc}     $out/share/calamares/branding/nixos/branding.desc
                    '';
                  });
                })
              ];
            }
            ( # Ce module définit les options de l'image ISO
              { config, ... }:
              {
                isoImage = {
                  volumeID = "GLF-OS-ALPHA-OMNISLASH_3";
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

        "user-test" = nixpkgs.lib.nixosSystem {
          inherit system specialArgs; # <<< Passer specialArgs ici aussi
          modules = baseModules ++ [
            {
              boot.loader.grub = {
                enable = true;
                device = "/dev/sda"; # Attention: ceci est pour une VM ou un test spécifique
                useOSProber = true;
              };

              fileSystems."/" = {
                device = "/dev/sda1"; # Attention: ceci est pour une VM ou un test spécifique
                fsType = "ext4";
              };
            }
          ];
        };
      };

      # Pas besoin de `inherit nixosModules;` si vous ne l'utilisez pas ailleurs

    }
    // utils.lib.eachDefaultSystem (
      system:
      let
        # pkgs est défini spécifiquement pour eachDefaultSystem,
        # il est différent du pkgs utilisé dans nixosSystem
        pkgs = import nixpkgs {
          inherit system;
          config = nixpkgsConfig; # Utilise la même config ici aussi
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.ruby
            pkgs.bundler
          ];
          shellHook = ''
            # Vérifier si le répertoire docs existe avant de s'y déplacer
            if [ -d "docs" ]; then
              cd docs || exit 1
              echo "Running bundle install and starting Jekyll server..."
              bundle config set path 'vendor/bundle' --local # Utiliser --local pour éviter de modifier le global
              # Pas besoin de répéter la commande bundle config set path
              bundle install
              bundle exec jekyll serve
            else
              echo "Directory 'docs' not found. Skipping Jekyll setup."
            fi
          '';
        };
      }
    );
}
