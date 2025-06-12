
{
  lib,
  config,
  pkgs,
  ...
}:

{

  config = lib.mkIf (config.glf.environment.enable && config.glf.environment.type == "plasma") {

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Activation de Plasma
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    services = {
      displayManager = {
        defaultSession = "plasma";
        sddm = {
          enable = true;
          theme = "breeze";
        };
      };
      desktopManager.plasma6.enable = true;
    };

    hardware.bluetooth.enable = true;

    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
      xdgOpenUsePortal = true;
    };

    systemd.services."getty@tty1".enable = false;
    systemd.services."autovt@tty1".enable = false;

    documentation.nixos.enable = false;

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Packages système
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    programs.kdeconnect.enable = true;

    systemPackages = with pkgs; [
      kdePackages.partitionmanager
      kdePackages.kpmcore
      ];

      plasma6.excludePackages = [ pkgs.kdePackages.discover ];
      systemPackages = [
        (pkgs.writeTextDir "share/sddm/themes/breeze/theme.conf.user" ''
          [General]
          background=/etc/wallpapers/glf/white.jpg
        '')
        ];
    };
  };

}
