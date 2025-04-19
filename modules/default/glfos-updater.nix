{
  lib,
  config,
  pkgs,
  ...
}:

let
  glfos-updater = pkgs.callPackage ../../pkgs/glfos-updater {};
in

{
  environment.systemPackages = with pkgs; [
      glfos-updater
  ];

  systemd.user.services.glfupdater = {
    enable = true;
    description = "Open GLF-OS Updater automatically";
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "/run/wrappers/bin/pkexec /run/current-system/sw/bin/glfos-updater";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };
}
