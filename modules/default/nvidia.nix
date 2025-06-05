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
    # Configuration hardware acceleration
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    # Variables d'environnement CUDA pour les applications
    environment.variables = {
      CUDA_PATH = "${pkgs.cudaPackages.cudatoolkit}";
      CUDA_HOME = "${pkgs.cudaPackages.cudatoolkit}";
      EXTRA_LDFLAGS = "-L/run/opengl-driver/lib";
      EXTRA_CCFLAGS = "-I/run/opengl-driver/include";
    };

    environment.systemPackages = with pkgs; [
      # Codecs NVIDIA pour l'encodage/décodage matériel
      nv-codec-headers
      
      # CUDA complet
      cudaPackages.cudatoolkit
      cudaPackages.cuda_runtime
      cudaPackages.cuda_nvcc
      
      # Support accélération matérielle
      libva
      libva-utils
      vaapiVdpau
      libvdpau-va-gl
    ];
  };
}
