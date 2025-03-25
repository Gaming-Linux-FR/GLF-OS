{
  lib,
  config,
  pkgs,
  ...
}:

{

  config = lib.mkIf (config.glf.environment.type == "mate") {

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Activation de Mate
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    services = {
      displayManager.defaultSession = "mate";
      power-profiles-daemon.enable = true;
      xserver = {
        displayManager.lightdm.enable = true;
        displayManager.lightdm.background = "/etc/wallpapers/glf/white.jpg";
        displayManager.lightdm.greeters.slick = {
          enable = true;
          iconTheme.name = "Tela-circle";
          theme.name = "adw-gtk3";
        };
        desktopManager.mate.enable = true;
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

        # Mate
        networkmanagerapplet
      ];
    };

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Paramètres Mate
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    programs.dconf = {
      enable = true;
      profiles.user.databases = [
        {
          settings = {
            "org/mate/desktop/interface" = {
              gtk-theme = "adw-gtk3";
              icon-theme = "Tela-circle";
            };

            "org/mate/desktop/background" = {
              color-shading-type = "solid";
              picture-options = "zoom";
              picture-filename = "file:///etc/wallpapers/glf/white.jpg";
            };
          };
        }
      ];
    };
  };

}
