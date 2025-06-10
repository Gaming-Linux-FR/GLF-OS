{
  lib,
  config,
  pkgs,
  pkgs-unstable,
  ...
}:
let
  plymouth-glfos = pkgs.callPackage ../../pkgs/plymouth-glfos {};
  amdgpu-kernel-module = pkgs.callPackage ./amdgpupatch/amdgpu-kernel-module.nix {
    kernel = config.boot.kernelPackages.kernel;
  };
in
{
  options.glf.boot.enable = lib.mkOption {
    description = "Enable GLF Boot configurations";
    type = lib.types.bool;
    default = true;
  };
  config = lib.mkIf config.glf.boot.enable {
    #GLF wallpaper as grub splashscreen
    boot.loader.grub.splashImage = ../../assets/wallpaper/dark.jpg;
    boot.loader.grub.default = "saved";
    boot.extraModulePackages = [
    (amdgpu-kernel-module.overrideAttrs (_: {
      patches = [./amdgpupatch/amdgpu-revert.patch];
    }))
  ];
    boot = {
      kernelPackages = pkgs.linuxPackages_6_12;
      tmp.cleanOnBoot = true;
      supportedFilesystems.zfs = lib.mkForce false; # Force disable ZFS
      kernelParams =
        if builtins.elem "kvm-amd" config.boot.kernelModules then [ "amd_pstate=active" "nosplit_lock_mitigate" "clearcpuid=514" ] else [ "nosplit_lock_mitigate" "clearcpuid=514" ];
      plymouth = {
        enable = true;
        theme = "glfos";
        themePackages = [ plymouth-glfos ];
      };
      kernel.sysctl = {
        vm_swappiness = 100;
        vm_vfs_cache_pressure = 50;
        vm_dirty_bytes = 268435456;
        "vm.page-cluster" = 0;
        vm_dirty_background_bytes = 67108864;
        vm_dirty_writeback_centisecs = 1500;
        kernel_nmi_watchdog = 0;
        kernel_unprivileged_userns_clone = 1;
        kernel_printk = "3 3 3 3";
        kernel_kptr_restrict = 2;
        kernel_kexec_load_disabled = 1;
      };
    }; 
    
    # Utiliser Mesa unstable directement depuis pkgs-unstable
    hardware.graphics = {
      enable = true;
      package = pkgs-unstable.mesa;
      package32 = pkgs-unstable.pkgsi686Linux.mesa;
    };
  }; 
}
