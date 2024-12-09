{ pkgs, ... }:
{
  services.flatpak.enable = true;
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    requires = [ "network-online.target" ];
    after = [ "network-online.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo && flatpak install -y flathub org.dupot.easyflatpak
    '';
  };

  environment.systemPackages = with pkgs;[
    # APP
    discord

    # Fetch en attendant GLF-FETCH
    fastfetch

    # Bureautique
    libreoffice-fresh
    hunspell
    hunspellDicts.fr-moderne
  ];
} 
