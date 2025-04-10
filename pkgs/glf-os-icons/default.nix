{ lib
, stdenv
, fetchurl
, librsvg
}:

let
  current_folder = ./.;
  icon = fetchurl {
    url = "file://${current_folder}/logo-glf-os.svg";
    sha256 = "39572c6157f690d6a61f8dd5f646fcd2d00c66e205b536ea9887f20b1e1f19e4";
  };
in

stdenv.mkDerivation rec {
  pname = "glf-os-icons";
  version = "1.0.0";
  nativeBuildInputs = [
    librsvg
  ];

  postInstall = ''
    for i in 16 24 48 64 96 128 256 512; do
      mkdir -p $out/share/icons/hicolor/''${i}x''${i}/apps
      rsvg-convert ${icon} -w ''${i} -h ''${i} -f svg -o $out/share/icons/hicolor/''${i}x''${i}/apps/glf-os-icon.svg
    done
  '';
  dontUnpack = true;
  dontBuild = true;
}
