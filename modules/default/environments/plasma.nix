{
  lib,
  config,
  pkgs,
  ...
}:

{

  config = lib.mkIf (config.glf.environment.type == "plasma") {

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Activation de Plasma
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    services = {
      displayManager.defaultSession = "plasma";
      xserver = {
        displayManager.sddm = {
          enable = true;
          theme = "breeze";
        };
        desktopManager.plasma6.enable = true;
      };
    };

    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-kde ];
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
      systemPackages = with pkgs; [
        writeTextDir "share/sddm/themes/breeze/theme.conf.user" ''
          [General]
          background = ${config.environment.etc."wallpapers/glf/white.jpg".source}
        ''
      ];
    };
  };

}
