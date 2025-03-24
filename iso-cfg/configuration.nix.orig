{ pkgs, lib, ... }:

{

  glf.autoUpgrade = lib.mkForce false;
  glf.nvidia_config.enable = true;

  i18n.defaultLocale = "fr_FR.UTF-8";

  console.keyMap = "fr";
  services.xserver = {
    enable = true;
    xkb.layout = "fr";
    xkb.variant = "";
    excludePackages = [ pkgs.xterm ];
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
