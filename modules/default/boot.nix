{ lib, config, pkgs, ... }:

let
  plymouth-glfos = pkgs.callPackage ../../pkgs/plymouth-glfos {};
  hasKvmAmd = builtins.elem "kvm-amd" config.hardware.cpu.kernelModules or [];
  finalKernelModules = if hasKvmAmd then
    [ "amd_pstate" "nosplit_lock_mitigate" ]
  else
    [ "nosplit_lock_mitigate" ];
in
{
  options.glf.boot.enable = lib.mkOption {
    description = "Enable GLF Boot configurations";
    type = lib.types.bool;
    default = true;
  };

  config = lib.mkIf config.glf.boot.enable {
    boot.loader.grub.splashImage = ../../assets/wallpaper/dark.jpg;

    boot = {
      tmp.cleanOnBoot = true;
      supportedFilesystems.zfs = lib.mkForce false;
      kernelModules = finalKernelModules;
      extraModulePackages = [ pkgs.xone ];
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
  };
}
