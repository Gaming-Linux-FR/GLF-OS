{
  # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  # NE TOUCHEZ A RIEN
  # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  imports = [
    ./hardware-configuration.nix
    ./glf
    ./glf/nvidia.nix
  ];

  users.users.test = {
    isNormalUser = true;
    description = "test";
    extraGroups = [ "networkmanager" "wheel" "render" ];
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

}
