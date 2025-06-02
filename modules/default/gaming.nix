{ config, pkgs, lib, pkgs-unstable, ... }: # Make sure 'lib' is included here
let
  system = "x86_64-linux";
in
{

  options.glf.gaming.enable = lib.mkOption { # Use 'lib.mkOption' here
    description = "Enable GLF Gaming configurations";
    type = lib.types.bool; # Use 'lib.types.bool' here
    default = if (config.glf.environment.edition != "mini") then
      true
    else
      false;
  };

  options.glf.mangohud.configuration = lib.mkOption { # Use 'lib.mkOption' here
    type = with lib.types; enum [ "disabled" "light" "full" ]; # Use 'lib.types' here
    default = "disabled";
    description = "MangoHud configuration";
  };

  config = lib.mkIf config.glf.gaming.enable { # Use 'lib.mkIf' here

    environment.systemPackages = with pkgs-unstable; [ # Utiliser pkgs-unstable
      heroic
      lutris
      mangohud
      wineWowPackages.staging
      winetricks
      joystickwake
      oversteer
      linuxKernel.packages.linux_libre.hid-tmff2
      mesa
      glxinfo
    ];

    environment.sessionVariables = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
      MANGOHUD_CONFIG = if config.glf.mangohud.configuration == "light" then
        ''control=mangohud,legacy_layout=0,horizontal,background_alpha=0,gpu_stats,gpu_power,cpu_stats,ram,vram,fps,fps_metrics=AVG,0.001,font_scale=1.05''
      else if config.glf.mangohud.configuration == "full" then
        ''control=mangohud,legacy_layout=0,vertical,background_alpha=0,gpu_stats,gpu_power,cpu_stats,core_load,ram,vram,fps,fps_metrics=AVG,0.001,frametime,refresh_rate,resolution, vulkan_driver,wine''
      else
        "";
    };

    services.udev.extraRules = ''
      # USB
      ATTRS{name}=="Sony Interactive Entertainment Wireless Controller Touchpad", ENV{LIBINPUT_IGNORE_DEVICE}="1"
      ATTRS{name}=="Sony Interactive Entertainment DualSense Wireless Controller Touchpad", ENV{LIBINPUT_IGNORE_DEVICE}="1"
      # Bluetooth
      ATTRS{name}=="Wireless Controller Touchpad", ENV{LIBINPUT_IGNORE_DEVICE}="1"
      ATTRS{name}=="DualSense Wireless Controller Touchpad", ENV{LIBINPUT_IGNORE_DEVICE}="1"
    '';

    hardware.fanatec.enable = true;
    #hardware.new-lg4ff_vff.enable = true;
    hardware.steam-hardware.enable = true;
    hardware.xone.enable = true;
    hardware.xpadneo.enable = true;
    programs.steam.gamescopeSession.enable = true;
    
programs.gamescope = {
  enable = true;
  capSysNice = true;
};

    programs.steam = {
      enable = true;
      package = pkgs.steam.override {
        extraEnv = {
          MANGOHUD = if config.glf.mangohud.configuration == "light" || config.glf.mangohud.configuration == "full" then
            true
          else
            false;
          OBS_VKCAPTURE = true;
        };
      };
      remotePlay.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      extraCompatPackages = with pkgs; [ proton-ge-bin ];
    };

  };

}
