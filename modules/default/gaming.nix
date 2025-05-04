{ config, pkgs, lib, pkgs-unstable, ... }:

let
  system = "x86_64-linux";
  edition = config.glf.environment.edition or "full"; # Ajout de la valeur par défaut
in
if edition == "mini" then
{
  # Si l'édition est "mini", on passe gaming.nix
}
else
{
  options.glf.mangohud.configuration = lib.mkOption {
    type = with lib.types; enum [ "disabled" "light" "full" ];
    default = "light";
    description = "MangoHud configuration";
  };

  # config = {

    environment.systemPackages = with pkgs-unstable; [
      heroic
      lutris
      mangohud
      wineWowPackages.staging
      winetricks
      joystickwake
      oversteer
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

    
    programs.steam.gamescopeSession.enable = true;

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
services.udev.extraRules = ''
      # USB
      ATTRS{name}=="Sony Interactive Entertainment Wireless Controller Touchpad", ENV{LIBINPUT_IGNORE_DEVICE}="1"
      ATTRS{name}=="Sony Interactive Entertainment DualSense Wireless Controller Touchpad", ENV{LIBINPUT_IGNORE_DEVICE}="1"
      # Bluetooth
      ATTRS{name}=="Wireless Controller Touchpad", ENV{LIBINPUT_IGNORE_DEVICE}="1"
      ATTRS{name}=="DualSense Wireless Controller Touchpad", ENV{LIBINPUT_IGNORE_DEVICE}="1"
    '';

    hardware.new-lg4ff.enable = true;
    hardware.steam-hardware.enable = true;
    hardware.xone.enable = true;
    hardware.xpadneo.enable = true;

}
