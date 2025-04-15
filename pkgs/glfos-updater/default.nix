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
    rev = "f9222b18434dc01e93b43f369add3efdce867133";
    sha256 = "sha256-cywhaDEuAyBFq/v/3AUWwCVvHmK38sPz0JWOoTCl4tk=";
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