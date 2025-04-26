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
    ];

    environment.etc."glfos/update.sh" = {
      text = ''
        #!${pkgs.bash}/bin/bash
        NH_FLAKE_PATH="/etc/nixos"
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
        else
          echo "[INFO] No changes detected in flake.lock. Skipping rebuild." >&2
        fi
      '';
      mode = "0755";
    };

    systemd = {
      services."glfos-update" = {
        description = "Update GLFOS";
        wantedBy = [ "multi-user.target" ];
        after = [ "network-online.target" ];
        requires = [ "network-online.target" ];
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
          Persistent = true;
        };
      };
    };

  };
}
