{
  lib,
  fetchFromGitHub,
  wrapGAppsHook4,
  meson,
  ninja,
  pkg-config,
  glib,
  glib-networking,
  desktop-file-utils,
  gettext,
  librsvg,
  blueprint-compiler,
  python3Packages,
  sassc,
  appstream-glib,
  libadwaita,
  gtk4,
  libportal,
  libportal-gtk4,
  libsoup_3,
  polkit,
  gobject-introspection,
}:

python3Packages.buildPythonApplication rec {
  pname = "nix-disk-manager";
  version = "1.2.3";

  src = fetchFromGitHub {
    owner = "Gaming-Linux-FR";
    repo = "nix-disk-manager";
    rev = version;
    sha256 = "sha256-k40ppm7jg9imi0Kd0lX4uzA/VTm4fy9hKeD/57keREI=";
  };

  format = "other";
  dontWrapGApps = true;

  nativeBuildInputs = [
    appstream-glib
    blueprint-compiler
    desktop-file-utils
    gettext
    glib
    gobject-introspection
    meson
    ninja
    wrapGAppsHook4
    pkg-config
  ];

  buildInputs = [
    libadwaita
    librsvg
    polkit.bin
  ];

  propagatedBuildInputs = with python3Packages; [
    pygobject3
  ];

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  meta = with lib; {
    description = "A simple GUI to manage disks on NixOS";
    license = licenses.gpl3Plus;
  };
}
