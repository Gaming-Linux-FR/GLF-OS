{
  lib,
  config,
  pkgs,
  pkgs-unstable,
  ...
}:
let
  plymouth-glfos = pkgs.callPackage ../../pkgs/plymouth-glfos {};

  nixpkgs_old_kernel = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/39f51ddad7a5.tar.gz";
    sha256 = "1g2j8043v7vm6ngxjlhsk0qwgzb1khjlwqigpdy9jdnr1lry4mgh";
  };
  pkgs_old_kernel = import nixpkgs_old_kernel {
    system = pkgs.system;
    config = config.nixpkgs.config;
  };

  pinnedKernelPackages = pkgs_old_kernel.linuxPackages;

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
      kernelPackages = pinnedKernelPackages;
      tmp.cleanOnBoot = true;
      supportedFilesystems.zfs = lib.mkForce false;
      kernelParams =
        if builtins.elem "kvm-amd" config.boot.kernelModules then [ "amd_pstate=active" "nosplit_lock_mitigate" ] else [ "nosplit_lock_mitigate" ];
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
