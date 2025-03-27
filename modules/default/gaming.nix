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
      mangohud
      wineWowPackages.staging
      winetricks
    ];

    environment.sessionVariables = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
      MANGOHUD_CONFIG = "control=mangohud,legacy_layout=0,horizontal,battery,time,time_format=%H\\:%M,gpu_stats,gpu_power,cpu_stats,ram,vram,fps,frametime=1,frame_timing=1,hud_no_margin,table_columns=14";
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
    programs = {
  gamescope = {
    enable = true;
    capSysNice = true;
  };
  steam = {
    enable = true;
    gamescopeSession.enable = true;
  };
};
hardware.xone.enable = true; # support for the xbox controller USB dongle
services.getty.autologinUser = "your_user";
environment = {
  systemPackages = [ pkgs.mangohud ];
  loginShellInit = ''
    [[ "$(tty)" = "/dev/tty1" ]] && ./gs.sh
  '';
};

  };

}
