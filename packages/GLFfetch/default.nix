{
  pkgs ? import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/550e11f27ba790351d390d9eca3b80ad0f0254e.tar.gz";
    sha256 = "0b2ya1730qb5dyhgvd6lvghfi7nw5pqq786rla4d32hsxjmqsx2k";
  }) {}
}:

pkgs.stdenv.mkDerivation rec {
  pname = "GLFfetch";
  version = "0.1.0";

  src = fetchTarball {
    url = "https://codeberg.org/Gaming-Linux-FR/GLFfetch/archive/dfa8d002d94efb50d8fc10172c8a0a1bda832025.tar.gz";
    sha256 = "1mzqibipv86ajmzgivj05cgl9wxyjj3h3wv0kiwf0nakbb2jm470";
  };

  propagatedBuildInputs = [
    pkgs.fastfetch
    pkgs.nerd-fonts.fantasque-sans-mono
  ];

  buildPhase = ''
    sed -i s#\\~/\\.config/fastfetch/GLFfetch#$out#g challenge.jsonc
  '';

  installPhase = ''
    cp -r . $out/
    mkdir $out/bin
    echo "#!/usr/bin/env sh" > $out/bin/GLFfetch
    echo >> $out/bin/GLFfetch
    echo '$(which fastfetch) --config '$out'/challenge.jsonc' >> $out/bin/GLFfetch
    chmod +x $out/bin/*
  '';

  #meta = with pkgs.stdenv.lib; {
  #  description = "A project which aims at making creating a small config file for all the GLF Linux challenges participants.";
  #  homepage = "https://codeberg.org/Gaming-Linux-FR/GLFfetch";
  #  license = licenses.mit;
  #  maintainers = with maintainers; [ ];
  #};
}
