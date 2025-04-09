{
  lib,
  config,
  pkgs,
  ...
}:

let
  nix-disk-manager = pkgs.callPackage ../../pkgs/nix-disk-manager {};
in

{
  environment.systemPackages = with pkgs; [
      nix-disk-manager
  ];
}
