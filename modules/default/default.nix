{ config, pkgs, lib, ... }:

{
  imports =
    [
      ./debug.nix
      ./aliases.nix
      ./boot.nix
      ./branding.nix
      ./environment.nix
      ./firefox.nix
      ./fstrim.nix
      ./gaming.nix
      ./nh.nix
      ./nvidia.nix
      ./packages.nix
      ./pipewire.nix
      ./printing.nix
      ./system.nix
      ./update.nix
      ./version.nix
      ./standBy.nix
      ./GLFfetch.nix
      ./nix-disk-manager.nix
      ./glfos-environment-selection.nix
      ./glfos-mangohud-configuration.nix
      ./fanatec.nix
    ];
 
}
