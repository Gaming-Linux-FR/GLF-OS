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
          paths = with pkgs.rocmPackages_6; [
            rocblas
            hipblas
            clr
          ];
        };
      in [
        "L+    /opt/rocm   -    -    -     -    ${rocmEnv}"
        "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages_6.clr}"
      ];

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    hardware.opengl.extraPackages = with pkgs.rocmPackages_6; [
      clr.icd # Assuming clr provides the ICD
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
          pkgs.rocmPackages_6.clr
          # Expanded ROCm packages for Blender-HIP (using _6 suffix)
          pkgs.rocmPackages_6.hip
          pkgs.rocmPackages_6.opencl-roc # This might still be incorrect, see below
          pkgs.rocmPackages_6.rocfft
          pkgs.rocmPackages_6.rocprim
          pkgs.rocmPackages_6.rocrand
          pkgs.rocmPackages_6.rocwmma
          pkgs.rocmPackages_6.amdsmi
          pkgs.rocmPackages_6.hipcub
          pkgs.rocmPackages_6.hipify
          pkgs.rocmPackages_6.hsakmt
          pkgs.rocmPackages_6.miopen
          pkgs.rocmPackages_6.rocgdb
          pkgs.rocmPackages_6.triton
          pkgs.rocmPackages_6.hipcc
          pkgs.rocmPackages_6.half
          pkgs.rocmPackages_6.rccl
          pkgs.rocmPackages_6.rdc
          pkgs.rocmPackages_6.tensile
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
          pkgs.rocmPackages_6.clr
          # Expanded ROCm packages for Blender-HIP (using _6 suffix)
          pkgs.rocmPackages_6.hipcc
          pkgs.rocmPackages_6.opencl-roc 
          pkgs.rocmPackages_6.rocfft
          pkgs.rocmPackages_6.rocprim
          pkgs.rocmPackages_6.rocrand
          pkgs.rocmPackages_6.rocwmma
          pkgs.rocmPackages_6.amdsmi
          pkgs.rocmPackages_6.hipcub
          pkgs.rocmPackages_6.hipify
          pkgs.rocmPackages_6.hsakmt
          pkgs.rocmPackages_6.miopen
          pkgs.rocmPackages_6.rocgdb
          pkgs.rocmPackages_6.triton
          pkgs.rocmPackages_6.half
          pkgs.rocmPackages_6.rccl
          pkgs.rocmPackages_6.rdc
          pkgs.rocmPackages_6.tensile
        ];
  };

}
