{ lib, config, pkgs, pkgs-unstable, ... }:
with lib;

let
  system = "x86_64-linux";

  xone = kernel: pkgs.stdenv.mkDerivation (finalAttrs: {
    pname = "xone";
    version = "0.3-unstable-2024-12-23";

    src = pkgs.fetchFromGitHub {
      owner = "dlundqvist";
      repo = "xone";
      rev = "6b9d59aed71f6de543c481c33df4705d4a590a31";
      hash = "sha256-MpxP2cb0KEPKaarjfX/yCbkxIFTwwEwVpTMhFcis+A4=";
    };

    setSourceRoot = ''
      export sourceRoot=$(pwd)/${finalAttrs.src.name}
    '';

    nativeBuildInputs = kernel.moduleBuildDependencies;

    makeFlags = [
      "-C"
      "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
      "M=$(sourceRoot)"
      "VERSION=${finalAttrs.version}"
    ];

    enableParallelBuilding = true;
    buildFlags = [ "modules" ];
    installFlags = [ "INSTALL_MOD_PATH=${placeholder "out"}" ];
    installTargets = [ "modules_install" ];

    meta = with lib; {
      description = "Linux kernel driver for Xbox One and Xbox Series X|S accessories";
      homepage = "https://github.com/dlundqvist/xone";
      license = licenses.gpl2Plus;
      maintainers = with lib.maintainers; [
        rhysmdnz
        fazzi
      ];
      platforms = platforms.linux;
      broken = kernel.kernelOlder "5.11";
    };
  });

  currentKernel = config.boot.kernelPackages.linux;

in
{
  options.glf.gaming.enable = mkOption {
    description = "Enable GLF Gaming configurations";
    type = types.bool;
    default = if (config.glf.environment.edition != "mini") then
      true
    else
      false;
  };

  config = mkIf config.glf.gaming.enable {
    environment.systemPackages = with pkgs-unstable; [
      heroic
      lutris
      mangohud
      wineWowPackages.staging
      winetricks
      joystickwake
    ];

    environment.sessionVariables = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
      MANGOHUD_CONFIG = ''control=mangohud,legacy_layout=0,horizontal,background_alpha=0,gpu_stats,gpu_power,cpu_stats,ram,vram,fps,fps_metrics=AVG,0.001,font_scale=1.05'';
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

    boot.extraModulePackages = [ (xone currentKernel) ]; # Passer le kernel comme argument
  };
}
