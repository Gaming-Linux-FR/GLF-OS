{ config, lib, pkgs, ... }:

{

  glf.autoUpgrade = lib.mkForce false;
  glf.nvidia_config.enable = true;
  specialisation = {
    nvidia_proprietary_driver = {
      configuration = {
        system.nixos.tags = lib.mkForce [ "nvidia_proprietary_driver" ];
        glf.nvidia_config.type = "proprietary";
      };
    };
  };

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
