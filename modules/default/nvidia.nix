{ config, lib, ... }:
with lib;
let
  cfg = config.glf.nvidia_config;
in
{
  # declare option
  options.glf.nvidia_config = {
    enable = mkOption {
      type = with types; bool;
      default = false;
      description = "Enable nvidia support";
    };
    type = mkOption {
      type = with types; enum [ "opensource" "proprietary" ];
      default = "opensource";
      description = "Select the nvidia driver version to use";
    };
    laptop = mkOption {
      type = with types; bool;
      default = false;
      description = "Enable nvidia laptop management";
    };
    intelBusId = mkOption {
      type = with types; nullOr str;
      default = null;
    };
    nvidiaBusId = mkOption {
      type = with types; nullOr str;
      default = null;
    };
    amdgpuBusId = mkOption {
      type = with types; nullOr str;
      default = null;
    };
  };

  # nvidia configuration
  config = mkIf cfg.enable {
    services.xserver.videoDrivers = [ "nvidia" "modesetting" "fbdev" ];
    boot.blacklistedKernelModules = [ "nouveau" ];

    hardware.nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.latest;

      open =
        if cfg.type == "opensource" then
          true
        else
          false;

      modesetting.enable = true;

      nvidiaSettings = true;

      prime = {
        intelBusId = optionalAttrs (cfg.intelBusId != null) cfg.intelBusId;
        nvidiaBusId = optionalAttrs (cfg.nvidiaBusId != null) cfg.nvidiaBusId;
        amdgpuBusId = optionalAttrs (cfg.amdgpuBusId != null) cfg.amdgpuBusId;
      };

      dynamicBoost.enable = cfg.laptop;
      powerManagement.enable = cfg.laptop;

    };
  };
}
