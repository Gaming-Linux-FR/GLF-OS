{ pkgs, lib, ... }:

{

  glf.autoUpgrade = lib.mkForce false;
  glf.packages.glf-os-environment-selection.enable = lib.mkForce false;
  glf.nvidia_config.enable = true;

  i18n.defaultLocale = "fr_FR.UTF-8";

  console.keyMap = "fr";
  services.xserver = {
    xkb.layout = "fr";
    xkb.variant = "";
  };

  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
      "render"
    ];
  };

  networking.hostName = "GLF-OS";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

}
