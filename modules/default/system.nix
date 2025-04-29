{
  lib,
  config,
  pkgs,
  ...
}:
time.hardwareClockInLocalTime = true;
{

  options.glf.system.enable = lib.mkOption {
    description = "Enable GLF systems configurations";
    type = lib.types.bool;
    default = true;
  };

  config = lib.mkIf config.glf.system.enable {

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        intel-gpu-tools
        intel-media-driver
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
        libva
        vulkan-loader
        vulkan-validation-layers
      ];
      extraPackages32 = with pkgs; [
        intel-gpu-tools
        intel-media-driver
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
        libva
       
      ];
    };

    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 25;
      priority = 5;
    };

    nix = {
      optimise = {
        automatic = true;
        dates = [ "weekly" ];
      };
      settings = {
        auto-optimise-store = true;
      };
    };

  };

}
