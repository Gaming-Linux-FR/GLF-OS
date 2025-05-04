{ config, pkgs, ... }:

let
  edition = config.glf.environment.edition or "full"; # Fallback 
in
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
    ]
    ++ lib.optional (edition != "mini") ./gaming.nix;
}
