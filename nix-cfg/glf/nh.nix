{ pkgs, ... }:
{
  environment.shellAliases = { rebuild = "nh os switch -f <nixpkgs/nixos> /etc/nixos/configuration.nix"; };

  environment.systemPackages = with pkgs; [ nh ];

  programs.nh = {
    enable = true;
    clean = {
      enable = true;
      dates = "weekly";
      extraArgs = "--keep-since 7d --keep 3";
    };
  };
}
