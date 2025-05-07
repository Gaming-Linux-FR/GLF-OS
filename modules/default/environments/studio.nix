{
  lib,
  config,
  pkgs,
  ...
}:

{
  config = lib.mkIf(config.glf.environment.enable && (config.glf.environment.edition == "studio" || config.glf.environment.edition == "studio-pro")) {
    systemd.tmpfiles.rules =
      let
        rocmEnv = pkgs.symlinkJoin {
          name = "rocm-combined";
          paths = with pkgs.rocmPackages; [
            rocblas
            hipblas
            clr
          ];
        };
      in [
        "L+    /opt/rocm   -    -    -     -    ${rocmEnv}"
        "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
      ];

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    hardware.graphics.extraPackages = with pkgs; [
      rocmPackages.clr.icd
    ];

    environment.variables = {
      # These might be useful for broader ROCm compatibility
      # ROC_ENABLE_PRE_VEGA = "1"; # Uncomment if you have older AMD GPUs
      # RUSTICL_ENABLE = "radeonsi"; # Likely handled by clr.icd
    };

    environment.systemPackages =
      if config.glf.environment.edition == "studio-pro" then
        with pkgs; [
          blender-hip
          obs-studio
          obs-studio-plugins.obs-vkcapture
          kdePackages.kdenlive
          davinci-resolve-studio
          gimp
          audacity
          freetube
          rocmPackages.clr
          # Expanded ROCm packages for Blender-HIP (Attempt 1: rocm-hip)
          rocmPackages.rocm-hip
          rocmPackages.opencl-roc
          rocmPackages.rocfft
          rocmPackages.rocprim
          rocmPackages.rocrand
          rocmPackages.rocwmma
          rocmPackages.amdsmi
          rocmPackages.hipcub
          rocmPackages.hipify
          rocmPackages.hsakmt
          rocmPackages.miopen
          rocmPackages.rocgdb
          rocmPackages.triton
          rocmPackages.hipcc
          rocmPackages.half
          rocmPackages.rccl
          rocmPackages.rdc
          rocmPackages.tensile
        ]
      else
        with pkgs; [
          blender-hip
          obs-studio
          obs-studio-plugins.obs-vkcapture
          kdePackages.kdenlive
          davinci-resolve
          gimp
          audacity
          freetube
          rocmPackages.clr
          # Expanded ROCm packages for Blender-HIP (Attempt 1: rocm-hip)
          rocmPackages.rocm-hip
          rocmPackages.opencl-roc
          rocmPackages.rocfft
          rocmPackages.rocprim
          rocmPackages.rocrand
          rocmPackages.rocwmma
          rocmPackages.amdsmi
          rocmPackages.hipcub
          rocmPackages.hipify
          rocmPackages.hsakmt
          rocmPackages.miopen
          rocmPackages.rocgdb
          rocmPackages.triton
          rocmPackages.hipcc
          rocmPackages.half
          rocmPackages.rccl
          rocmPackages.rdc
          rocmPackages.tensile
        ];
  };

}
