{
  lib,
  config,
  pkgs,
  ...
}:

{
  options.glf.autoUpgrade = lib.mkOption {
    description = "Enable GLFOS auto-upgrade.";
    type = lib.types.bool;
    default = true;
  };

  config = lib.mkIf config.glf.autoUpgrade {

    environment.systemPackages = with pkgs; [
      coreutils
      gawk
	  libnotify
	  shadow
    ];

    services.systembus-notify.enable = true;

    environment.etc."glfos/update.sh" = {
      text = ''
#!${pkgs.bash}/bin/bash

#changement de flake.nix
# Suppression de l'ancien flake.nix
rm -f /etc/nixos/flake.nix

# Création du nouveau flake.nix
cat <<'EOF' > /etc/nixos/flake.nix
{
  description = "GLF-OS ISO Configuration - Installer Evaluation Flake";
  
  inputs = {
    glf-channels.url = "git+https://framagit.org/gaming-linux-fr/glf-os/channels-glfos/testing-channels.git?ref=main"; #Repos responsable de la bascule d'une stable à une autre
    nixpkgs.follows = "glf-channels/nixpkgs";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    glf.url = "git+https://framagit.org/gaming-linux-fr/glf-os/glf-os.git?ref=testing"; # Référence le flake racine
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
      system = "x86_64-linux"; 

      # Configuration pour le nixpkgs stable (sera le 'pkgs' par défaut)
      pkgsStable = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      # Configuration pour le nixpkgs unstable (sera passé en argument spécial)
      pkgsUnstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations."GLF-OS" = nixpkgs.lib.nixosSystem {
        inherit system; # Maintenant 'system' est défini
        pkgs = pkgsStable; 
        modules = [
          ./configuration.nix 
          glf.nixosModules.default 
        ];

        specialArgs = {
          pkgs-unstable = pkgsUnstable; 
        };
      };
    };
}
EOF






_notify() {
lang="''${LANG:-en}"
case "''${lang%%_*}" in
fr)
    title="''${1:-Mise à jour système}"
    message="''${2:-Le système a été mis à jour. Les changements prendront effet au prochain démarrage.}"
    ;;
*)
    title="''${3:-System Update}"
    message="''${4:-The system has been updated. Changes will take effect on the next reboot.}"
    ;;
esac
    	
for path in /run/user/*; do
  uid="''$(basename "$path")"
  user="''$(id -nu "$uid")"
  /run/current-system/sw/bin/runuser -u "''${user}" -- env \
    XDG_RUNTIME_DIR="/run/user/''${uid}" \
    DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/''${uid}/bus" \
    /run/current-system/sw/bin/notify-send \
      -a "GLF-Update" \
      -i "/run/current-system/sw/share/icons/hicolor/256x256/emblems/glfos-logo-light.png" \
      "''${title}" \
      "''${message}"
done
}
	
FLAKE_PATH="/etc/nixos"
FLAKE_NAME="GLF-OS"

FLAKE_LOCK_PATH="/etc/nixos/flake.lock"
INITIAL_HASH=$(${pkgs.coreutils}/bin/sha256sum "$FLAKE_LOCK_PATH" | ${pkgs.gawk}/bin/awk '{print $1}')

# Check network status
if ! ${pkgs.networkmanager}/bin/nm-online -q; then
  echo "[ERROR] Network is not yet online" >&2
  exit 1
fi

echo "[INFO] Updating Flatpaks..." >&2
${pkgs.flatpak}/bin/flatpak update -y
if [ $? -ne 0 ]; then
  echo "[ERROR] Flatpak update failed" >&2
  exit 1
fi
echo "[INFO] Flatpak update completed successfully." >&2

echo "[INFO] Starting flake update for $FLAKE_PATH" >&2
${pkgs.nix}/bin/nix flake update --flake $FLAKE_PATH
if [ $? -ne 0 ]; then
  echo "[ERROR] Flake update failed for $FLAKE_PATH" >&2
  exit 1
fi

UPDATED_HASH=$(${pkgs.coreutils}/bin/sha256sum "$FLAKE_LOCK_PATH" | ${pkgs.gawk}/bin/awk '{print $1}')

if [ "$INITIAL_HASH" != "$UPDATED_HASH" ]; then
  echo "[INFO] flake.lock has changed. Rebuilding the system..." >&2
  ${pkgs.nixos-rebuild}/bin/nixos-rebuild boot --flake $FLAKE_PATH#$FLAKE_NAME
  if [ $? -ne 0 ]; then
    echo "[ERROR] System rebuild failed for $FLAKE_NAME" >&2
    exit 1
  fi
  echo "[INFO] GLFOS update and rebuild completed successfully." >&2

  # On lance le clean
  echo "[INFO] Cleaning up old system generations..." >&2
  ${pkgs.nix}/bin/nix-collect-garbage --delete-older-than 2d
  if [ $? -ne 0 ]; then
    echo "[WARNING] Failed to cleanup old generations." >&2
  else
    echo "[INFO] Old generations cleanup completed." >&2
  fi
  # Lance la notification
  _notify
          
else
  echo "[INFO] No changes detected in flake.lock. Skipping rebuild." >&2
  _notify "Mise à jour GLF-OS" \
  "Le système a été mis à jour." \
  "GLF-OS Update" \
  "The system has been updated."
fi
'';
    mode = "0755";
    };

    systemd = {
      services."glfos-update" = {
        description = "Update GLFOS";
        wantedBy = [ ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = [
            "${pkgs.bash}/bin/bash"
            "/etc/glfos/update.sh"
          ];
        };
      };
      timers."glfos-update" = {
        description = "Run GLFOS Auto-update script";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "5min";
          OnUnitActiveSec = "12h";
        };
        after = [ "network-online.target" ];
    	requires = [ "network-online.target" ];
      };
    };

  };
}
