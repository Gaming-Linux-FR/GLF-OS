{ lib, config, pkgs, pkgs-unstable, ... }:

let
  plymouth-glfos = pkgs.callPackage ../../pkgs/plymouth-glfos {};

  # Utiliser une version spécifique du noyau
  GLFkernel = pkgs.linuxPackages_latest_6_14.kernel;
  
  # Utiliser les paquets pour cette version du noyau
  GLFkernelPackages = pkgs.linuxPackages_latest_6_14;
  
  # Vérifier si la version spécifique existe
  GLFkernelPackages_6_14_8 = builtins.getAttr "linuxPackages_6_14" pkgs;
  
  # Utiliser le noyau 6.14.8 si disponible, sinon utiliser la version par défaut
  selectedKernelPackages = if builtins.hasAttr "linux_6_14_8" GLFkernelPackages_6_14_8 then
                              GLFkernelPackages_6_14_8.linuxPackages_6_14_8
                          else
                              GLFkernelPackages;
  
in
{
  options.glf.boot.enable = lib.mkOption {
    description = "Enable GLF Boot configurations";
    type = lib.types.bool;
    default = true;
  };

  config = lib.mkIf config.glf.boot.enable {
    boot.loader.grub.splashImage = ../../assets/wallpaper/dark.jpg;
    boot.loader.grub.default = "saved";
    boot = {
      kernelPackages = selectedKernelPackages;
      tmp.cleanOnBoot = true;
      supportedFilesystems.zfs = lib.mkForce false;
      kernelParams =
        if builtins.elem "kvm-amd" config.boot.kernelModules then
          [ "amd_pstate=active" "nosplit_lock_mitigate" ]
        else
          [ "nosplit_lock_mitigate" ];
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

    hardware.graphics = {
      enable = true;
      package = pkgs-unstable.mesa;
      package32 = pkgs-unstable.pkgsi686Linux.mesa;
    };
  };
}
