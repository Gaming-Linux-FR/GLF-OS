{
  lib,
  config,
  pkgs,
  ...
}:

let
  glfos-branding = pkgs.callPackage ../../pkgs/glfos-branding {};
in
{
  options.glf.gnome.enable = lib.mkOption {
    description = "Enable GLF Gnome configurations";
    type = lib.types.bool;
    default = true;
  };

  config = lib.mkIf config.glf.gnome.enable {

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Activation de GNOME
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    services = {
      udev.packages = [ pkgs.gnome-settings-daemon ];
      xserver = {
        displayManager.gdm.enable = lib.mkDefault true;
        desktopManager.gnome = {
          enable = lib.mkDefault true;

          # Activation du Fractional Scaling
          extraGSettingsOverridePackages = [ pkgs.mutter ];
          extraGSettingsOverrides = ''
              [org.gnome.mutter]
            experimental-features=['scale-monitor-framebuffer']
          '';
        };
      };
    };

    documentation.nixos.enable = false;

    systemd.services."getty@tty1".enable = false;
    systemd.services."autovt@tty1".enable = false;

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Packages système
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    programs.kdeconnect = {
      enable = true;
      package = pkgs.gnomeExtensions.gsconnect;
    };

    environment = {
      systemPackages = with pkgs; [

        # theme
        adw-gtk3
        graphite-gtk-theme
        tela-circle-icon-theme

        # gnome
        gnome-tweaks

        # Extension
        gnomeExtensions.caffeine
        gnomeExtensions.gsconnect
        gnomeExtensions.appindicator
        gnomeExtensions.dash-to-dock
        gnomeExtensions.bing-wallpaper-changer
        gnomeExtensions.quick-settings-audio-panel

      ];

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Paquets exclus de l'installation de GNOME
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      gnome.excludePackages = with pkgs; [
        tali
        iagno
        hitori
        atomix
        yelp
        geary
        xterm
        totem

        epiphany
        packagekit

        gnome-tour
        gnome-software
        gnome-contacts
        gnome-user-docs
        gnome-packagekit
        gnome-font-viewer
      ];

      etc = {
        "wallpapers/glf/white.jpg".source = ../../assets/wallpaper/white.jpg;
        "wallpapers/glf/dark.jpg".source = ../../assets/wallpaper/dark.jpg;
      };
    };

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Paramètres GNOME
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    programs.dconf = {
      enable = true;
      profiles.gdm.databases = [
        {
          settings."org/gnome/login-screen" = {
            logo = ''${glfos-branding}/share/icons/hicolor/48x48/emblems/glfos-logo-light.png'';
          };
        }
      ];
      profiles.user.databases = [
        {
          settings = {
            "org/gnome/desktop/wm/preferences" = {
              button-layout = "appmenu:minimize,maximize,close";
              theme = "adw-gtk3";
              focus-mode = "click";
              visual-bell = false;
            };

            "org/gnome/desktop/interface" = {
              cursor-theme = "Adwaita";
              gtk-theme = "adw-gtk3";
              icon-theme = "Tela-circle";
            };

            "org/gnome/desktop/background" = {
              color-shading-type = "solid";
              picture-options = "zoom";
              picture-uri = "file:///${config.environment.etc."wallpapers/glf/white.jpg".source}";
              picture-uri-dark = "file:///${config.environment.etc."wallpapers/glf/dark.jpg".source}";
            };

            "org/gnome/desktop/peripherals/touchpad" = {
              click-method = "areas";
              tap-to-click = true;
              two-finger-scrolling-enabled = true;
            };

            "org/gnome/desktop/peripherals/keyboard" = {
              numlock-state = true;
            };

            "org/gnome/shell" = {
              disable-user-extensions = false;
              enabled-extensions = [
                "caffeine@patapon.info"
                "gsconnect@andyholmes.github.io"
                "appindicatorsupport@rgcjonas.gmail.com"
                "dash-to-dock@micxgx.gmail.com"
              ];
              favorite-apps = [
                "vivaldi-stable.desktop"
                "steam.desktop"
                "net.lutris.Lutris.desktop"
                "com.heroicgameslauncher.hgl.desktop"
                "discord.desktop"
                "thunderbird.desktop"
                "org.gnome.Nautilus.desktop"
                "org.dupot.easyflatpak.desktop"
                "org.gnome.Calendar.desktop"
              ];
            };

            "org/gnome/shell/extensions/dash-to-dock" = {
              click-action = "minimize-or-overview";
              disable-overview-on-startup = true;
              dock-position = "BOTTOM";
              running-indicator-style = "DOTS";
              isolate-monitor = false;
              multi-monitor = true;
              show-mounts-network = true;
              always-center-icons = true;
              custom-theme-shrink = true;
            };

            "org/gnome/mutter" = {
              check-alive-timeout = lib.gvariant.mkUint32 30000;
              dynamic-workspaces = true;
              edge-tiling = true;
            };
          };
        }
      ];
    };
  };

}
