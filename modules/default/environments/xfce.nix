{
  lib,
  config,
  pkgs,
  ...
}:

{

  config = lib.mkIf (config.glf.environment.type == "xfce") {

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Activation de Xfce
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    services = {
      displayManager.defaultSession = "xfce";
      xserver = {
        displayManager.lightdm.enable = true;
        displayManager.lightdm.background = "/etc/wallpapers/glf/white.jpg";
        displayManager.lightdm.greeters.slick = {
          enable = true;
          iconTheme.name = "Tela-circle";
          theme.name = "adw-gtk3";
        };
        desktopManager.xfce.enable = true;
      };
    };

    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      xdgOpenUsePortal = true;
    };

    documentation.nixos.enable = false;

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Packages système
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    environment = {
      systemPackages = with pkgs; [

        # Theme
        adw-gtk3
        graphite-gtk-theme
        tela-circle-icon-theme

        # Xfce
        xfce.xfce4-pulseaudio-plugin
      ];
      xfce.excludePackages = with pkgs; [
        xfce.xfce4-appfinder
        xfce.xfce4-taskmanager
      ];
    };

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Paramètres Xfce
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    programs.thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        thunar-archive-plugin
        thunar-media-tags-plugin
        thunar-volman
      ];
    };
  };

}
