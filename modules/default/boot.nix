{
  lib,
  config,
  pkgs,
  pkgs-unstable,
  ...
}:
let
  plymouth-glfos = pkgs.callPackage ../../pkgs/plymouth-glfos {};

  kernel6_14_8_store_path = "/nix/store/nrd1sf5aqgyhnbjqi30ip99w8xpcx1hw-linux-6.14.8";

  pinnedKernelPackages = pkgs.recurseIntoAttrs {
    inherit (pkgs) stdenv lib;

    kernel = pkgs.symlinkJoin {
      name = "linux-6.14.8";
      paths = [ "${kernel6_14_8_store_path}/bzImage" ];
    };

    out = pkgs.symlinkJoin {
      name = "linux-6.14.8-out";
      paths = [ kernel6_14_8_store_path ];
    };

    dev = pkgs.symlinkJoin {
      name = "linux-6.14.8-dev";
      paths = [ "${kernel6_14_8_store_path}/dev" ];
    };

    version = "6.14.8";
  };

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
