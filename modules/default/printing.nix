{
  lib,
  config,
  pkgs,
  ...
}:

{
  options.glf.printing.enable = lib.mkOption {
    description = "Enable GLF printing configurations.";
    type = lib.types.bool;
    default = true;
  };

  config = lib.mkIf config.glf.printing.enable (
    let
      allUsers = builtins.attrNames config.users.users;
      normalUsers = builtins.filter (user: config.users.users.${user}.isNormalUser) allUsers;

      # contexte: https://github.com/NixOS/nixpkgs/issues/391727
      hplipPluginMirror = "https://www.openprinting.org/download/printdriver/auxfiles/HP/plugins";
      hplipWithPluginFix = pkgs.hplipWithPlugin.overrideAttrs (prev: {
        plugin = pkgs.fetchurl {
          url = "${hplipPluginMirror}/${prev.pname}-${prev.version}-plugin.run";
          hash = "sha256-Hzxr3SVmGoouGBU2VdbwbwKMHZwwjWnI7P13Z6LQxao=";
        };
      });
    in
    {
      services = {

        # Configure printer
        printing = {
          enable = true;
          startWhenNeeded = true;
          drivers = with pkgs; [
            brgenml1cupswrapper
            brgenml1lpr
            brlaser
            cnijfilter2
            epkowa
            gutenprint
            gutenprintBin
            hplipWithPluginFix
            samsung-unified-linux-driver
            splix
          ];
        };

        # Enable autodiscovery
        avahi = {
          enable = true;
          nssmdns4 = true;
          openFirewall = true;
        };

        udev.packages = with pkgs; [
          sane-airscan
          utsushi
        ];
      };

      # systemd.services.cups-browsed.enable = false;
      hardware.sane = {
        enable = true;
        extraBackends = with pkgs; [
          hplipWithPlugin
          sane-airscan
          epkowa
          utsushi
        ];
      };

      # To install printers manually
      programs.system-config-printer.enable = true;

      # add all users to group scanner and lp
      users.groups.scanner.members = normalUsers;
      users.groups.lp.members = normalUsers;
    }
  );
}
