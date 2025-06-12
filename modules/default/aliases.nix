{
  lib,
  config,
  pkgs,
  ...
}:

{

  options.glf.aliases.enable = lib.mkOption {
    description = "Enable GLF Aliases configurations";
    type = lib.types.bool;
    default = true;
  };

  config = lib.mkIf config.glf.aliases.enable {

    environment = {
      systemPackages = with pkgs; [
        pciutils
        util-linux
        inxi
        gawk
      ];
      shellAliases = {
        glf-update = "sudo nix flake update --flake /etc/nixos && nh os boot /etc/nixos -H GLF-OS";
        glf-build = "nh os build /etc/nixos -H GLF-OS";
        glf-switch = "nh os switch /etc/nixos -H GLF-OS";
        glf-diff = "nix store diff-closures $(ls -d1v /nix/var/nix/profiles/system-*-link | tail -n 2)";
        glf-systeminfo = ''
          	    echo -e "\n--- Infos ---"; \
          	    inxi -M; \
          	    echo -e "\n--- CPU ---"; \
          	    lscpu | grep -E "(Architecture|CPU op-mode|Vendor ID|Model name|Mode\\(s\\) opératoire\\(s\\) des processeurs|Identifiant constructeur|Nom de modèle)" | awk "{print \$0}"; \
          	    echo -e "\n--- GPU ---"; \
          	    lspci | grep -E "VGA|3D"; \
          	    echo -e "\n--- Disque ---"; \
          	    df -h; \
          	    echo -e "\n--- RAM ---"; \
          	    free -h
          	'';        
      };
    };

  };

}
