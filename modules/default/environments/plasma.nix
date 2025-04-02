{
  lib,
  config,
  pkgs,
  ...
}:

{

  config = lib.mkIf (config.glf.environment.type == "plasma" || config.glf.environment.type == "studio" || config.glf.environment.type == "studio-pro") {

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

    environment = {
      systemPackages = [
        (pkgs.writeTextDir "share/sddm/themes/breeze/theme.conf.user" ''
          [General]
          background=/etc/wallpapers/glf/white.jpg
        '')
      ];
    };
  };

}
