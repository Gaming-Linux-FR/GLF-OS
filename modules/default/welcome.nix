{
  lib,
  config,
  pkgs,
  ...
}:

let
  nix-disk-manager = pkgs.callPackage ../../pkgs/glfos-welcome-screen {};
in

{
  environment.systemPackages = with pkgs; [
      glfos-welcome-screen
  ];
}
