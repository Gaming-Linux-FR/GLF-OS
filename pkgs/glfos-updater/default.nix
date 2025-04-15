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
  pname = "glfos-updater";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "Gaming-Linux-FR";
    repo = "glfos-updater";
    rev = "5c7b2a9eb242d5b9cb26be8eccafdc5cc7b1bba9";
    sha256 = "sha256-k7pFsggbTE1y9dui92Ux569xz5iX1d/tS83EGG5EdPg=";
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
    requests
  ];

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  preConfigure = ''
    substituteInPlace ./data/org.glfos.updater.in --subst-var-by out $out
  '';

  postInstall = ''
    mkdir -p $out/etc/xdg/autostart
    cp $out/share/applications/glfos-updater.desktop $out/etc/xdg/autostart/
  '';

  meta = with lib; {
    description = "A simple GUI to manage updates on GLF-OS";
    license = licenses.mit;
  };
}