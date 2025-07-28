{
  lib,
  config,
  pkgs,
  ...
}:

let
  nix-disk-manager = pkgs.callPackage ../../pkgs/welcome-screen {};
in

{
  environment.systemPackages = with pkgs; [
     welcome-screen
  ];
}
