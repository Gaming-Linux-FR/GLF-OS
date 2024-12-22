{ lib, config, pkgs, ... }:
{
  # =================================================================================================
  # ISO CONFIGURATION
  # =================================================================================================

  nixpkgs.hostPlatform = "x86_64-linux";

  # boot.supportedFilesystems = lib.mkForce [ "btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" ];

  # ====================================
  # Grub theme
  # ====================================

  # boot.plymouth.enable = true;
  # boot.plymouth.logo = "/iso/nix-cfg/rice/logo-glf-os.svg";

  # boot.loader.grub = {
  #   enable = true;
  #   efisupport = true;
  #   useosprober = true;
  #   splashimage = "/iso/nix-cfg/rice/boot.png";
  # };


  # ====================================
  # Keyboard layout
  # ====================================
  console.keyMap = "fr";
  services.xserver = {
    enable = true;
    xkb.layout = "fr";
    xkb.variant = "";
    excludePackages = [ pkgs.xterm ];
  };

  # ====================================
  # Nvidia Drivers
  # ====================================
  nixpkgs.config.nvidia.acceptLicense = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
    nvidiaSettings = true;
    modesetting.enable = true;
  };

  # ====================================
  # Define ISO User
  # ====================================
  users.users.test = {
    isNormalUser = true;
    description = "test";
    extraGroups = [ "networkmanager" "wheel" "render" ];
  };

  # ====================================
  # Nix config
  # ====================================
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];

    system-features = [
      "kvm"
      "big-parallel"
      "gccarch-skylake"
    ];

    substituters = [
      "https://nix-community.cachix.org"
      "https://cuda-maintainers.cachix.org"
    ];

    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
    ];
  };

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Paramètre GNOME
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  environment.systemPackages = with pkgs;[
    # theme
    adw-gtk3
    graphite-gtk-theme
    tela-circle-icon-theme
  ];

  programs.dconf = {
    enable = true;
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
            picture-uri = "file:///iso/nix-cfg/glf/rice/white.jpg";
            picture-uri-dark = "file:///iso/nix-cfg/glf/rice/dark.jpg";
          };

          "org/gnome/desktop/peripherals/touchpad" = {
            click-method = "areas ";
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
              "firefox.desktop"
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
            dock-position = "BOTTOM";
            isolate-monitor = false;
            multi-monitor = true;
            show-mounts-network = true;
            always-center-icons = true;
            custom-theme-shrink = true;
            dock-fixed = false;
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
}
