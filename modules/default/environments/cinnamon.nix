{
  lib,
  config,
  pkgs,
  ...
}:

{

  config = lib.mkIf (config.glf.environment.type == "cinnamon") {

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Activation de Cinnamon
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    services = {
      displayManager.defaultSession = "cinnamon";
      power-profiles-daemon.enable = true;
      xserver = {
        displayManager.lightdm.enable = true;
        displayManager.lightdm.background = "/etc/wallpapers/glf/white.jpg";
        displayManager.lightdm.greeters.slick = {
          enable = true;
          iconTheme.name = "Tela-circle";
          theme.name = "adw-gtk3";
        };
        desktopManager.cinnamon.enable = true;
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
      ];
    };

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Paramètres Cinnamon
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    programs.dconf = {
      enable = true;
      profiles.user.databases = [
        {
          settings = {
            "org/cinnamon/desktop/interface" = {
              cursor-theme = "Adwaita";
              gtk-theme = "adw-gtk3";
              icon-theme = "Tela-circle";
            };

            "org/cinnamon/desktop/background" = {
              color-shading-type = "solid";
              picture-options = "zoom";
              picture-uri = "file:///etc/wallpapers/glf/white.jpg";
              picture-uri-dark = "file:///etc/wallpapers/glf/dark.jpg";
            };
          };
        }
      ];
    };
  };

}
