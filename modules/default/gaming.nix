{ config, pkgs, lib, pkgs-unstable, ... }:
let
  system = "x86_64-linux";
in
{
  options.glf.gaming.enable = lib.mkOption {
    description = "Enable GLF Gaming configurations";
    type = lib.types.bool;
    default = if (config.glf.environment.edition != "mini") then
      true
    else
      false;
  };
  
  options.glf.mangohud.configuration = lib.mkOption {
    type = with lib.types; enum [ "disabled" "light" "full" ];
    default = "disabled";
    description = "MangoHud configuration";
  };
  
  config = lib.mkIf config.glf.gaming.enable {
    environment.systemPackages = with pkgs-unstable; [
      # Lutris Config with additional libraries
      (lutris.override {
        extraLibraries = p: [ p.libadwaita p.gtk4 ];
      })
      
      # Gaming tools
      glxinfo          # Show hardware information
      lug-helper       # help to install Star Citizen
      heroic           # Native GOG, Epic, and Amazon Games Launcher for Linux, Windows and Mac
      joystickwake     # Joystick-aware screen waker
      linuxKernel.packages.linux_6_15.hid-tmff2
      mangohud         # Vulkan and OpenGL overlay for monitoring FPS, temperatures, CPU/GPU load and more
      mesa             # Ensure last mesa stable on GLF OS
      oversteer        # Steering Wheel Manager for Linux
      umu-launcher     # Unified launcher for Windows games on Linux using the Steam Linux Runtime and Tools
      wineWowPackages.staging # Open Source implementation of the Windows API on top of X, OpenGL, and Unix (with staging patches)
      winetricks       # Script to install DLLs needed to work around problems in Wine
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
    
    # Hardware support
    #hardware.fanatec.enable = true;
    hardware.new-lg4ff_vff.enable = true;
    hardware.steam-hardware.enable = true;
    hardware.xone.enable = true;
    hardware.xpadneo.enable = true;
    hardware.opentabletdriver.enable = true;
    
    # Gamescope configuration
    programs.gamescope = {
      enable = true;
      capSysNice = true;
    };
    
    # Steam configuration
    programs.steam = {
      enable = true;
      gamescopeSession.enable = true;
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
