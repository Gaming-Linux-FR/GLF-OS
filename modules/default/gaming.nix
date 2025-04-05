{
  lib,
  config,
  pkgs,
  ...
}:

{

  options.glf.gaming.enable = lib.mkOption {
    description = "Enable GLF Gaming configurations";
    type = lib.types.bool;
    default = true;
  };

  config = lib.mkIf config.glf.gaming.enable {

    environment.systemPackages = with pkgs; [
      heroic
      lutris
      vulkan-tools
      mangohud
      wineWowPackages.staging
      winetricks
    ];

    environment.sessionVariables = {
  STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
MANGOHUD_CONFIG = ''control=mangohud,legacy_layout=0,horizontal,background_alpha=0,gpu_stats,gpu_power,cpu_stats,ram,vram,fps,fps_metrics=AVG,fps_metrics=0.001,font_scale=1.05'';
};

    services.udev.extraRules = ''
      # USB
      ATTRS{name}=="Sony Interactive Entertainment Wireless Controller Touchpad", ENV{LIBINPUT_IGNORE_DEVICE}="1"
      ATTRS{name}=="Sony Interactive Entertainment DualSense Wireless Controller Touchpad", ENV{LIBINPUT_IGNORE_DEVICE}="1"
      # Bluetooth
      ATTRS{name}=="Wireless Controller Touchpad", ENV{LIBINPUT_IGNORE_DEVICE}="1"
      ATTRS{name}=="DualSense Wireless Controller Touchpad", ENV{LIBINPUT_IGNORE_DEVICE}="1"
    '';

    hardware.steam-hardware.enable = true;
    hardware.xpadneo.enable = true;
    programs.steam.gamescopeSession.enable = true;

    programs.steam = {
      enable = true;
      package = pkgs.steam.override {
        extraEnv = {
          MANGOHUD = true;
          OBS_VKCAPTURE = true;
        };
      };
      remotePlay.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      extraCompatPackages = with pkgs; [ proton-ge-bin ];
    };

  };

}
