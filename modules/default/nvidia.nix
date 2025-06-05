{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.glf.nvidia_config;
in
{
  options.glf.nvidia_config = {
    enable = mkOption {
      type = with types; bool;
      default = false;
      description = "Enable nvidia support";
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

  config = mkIf cfg.enable {
    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.latest;
      open = true;
      cudaPackages = with config.cudaPackages; [ cuda_toolkit ];
      nvidiaSettings = true;
      modesetting.enable = true;

      prime = {
        intelBusId = optionalAttrs (cfg.intelBusId != null) cfg.intelBusId;
        nvidiaBusId = optionalAttrs (cfg.nvidiaBusId != null) cfg.nvidiaBusId;
        amdgpuBusId = optionalAttrs (cfg.amdgpuBusId != null) cfg.amdgpuBusId;
      };

      dynamicBoost.enable = cfg.laptop;
      powerManagement.enable = cfg.laptop;
    };

    environment.systemPackages = with pkgs; [
      nv-codec-headers
    ];
  };
}
