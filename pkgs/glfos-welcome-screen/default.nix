{ 
  lib,
  stdenvNoCC,
  makeDesktopItem,
  makeWrapper,
  fetchzip,
  glib,
  nspr,
  at-spi2-atk,
  cups,
  dbus,
  libdrm,
  gdk-pixbuf,
  gtk3,
  pango,
  cairo,
  fontconfig,
  xorg,
  mesa,
  expat,
  libxkbcommon,
  harfbuzz,
  libepoxy,
  alsa-lib
}:

let
  desktopFile = makeDesktopItem {
    name = "glfos-welcome-screen";
    desktopName = "Welcome Screen";
    exec = "glfos-welcome-screen";
    icon = "glfos-welcome-screen";
    startupWMClass ="org.dupot.glfos_welcome_screen";
  };
in
stdenvNoCC.mkDerivation rec {
  pname = "glfos-welcome-screen";
  version = "1.6.10";
  
  nativeBuildInputs = [makeWrapper];
  buildInputs = [
    glib # libgobject-2.0.so.0, libglib-2.0.so.0, libgio-2.0.so.0
    nspr # libnspr4.so
    at-spi2-atk # libatk-1.0.so.0, libatk-bridge-2.0.so.0
    cups
    dbus
    fontconfig
    harfbuzz
    libepoxy
    libdrm # libdrm.so.2
    gdk-pixbuf # libgdk_pixbuf-2.0.so.0
    gtk3 # libgtk-3.so.0
    pango # libpango-1.0.so.0
    cairo # libcairo.so.2
    xorg.libX11 # libX11.so.6
    xorg.libXcomposite # libXcomposite.so.1
    xorg.libXdamage # libXdamage.so.1
    xorg.libXext # libXext.so.6
    xorg.libXfixes # libXfixes.so.3
    xorg.libXrandr # libXrandr.so.2
    mesa # libgbm.so.1
    expat # libexpat.so.1
    xorg.libxcb # libxcb.so.1
    libxkbcommon # libxkbcommon.so.0
    alsa-lib # libasound.so.2
  ];
  
  src = fetchzip {
    url = "https://github.com/imikado/glfos-welcome-screen/releases/download/${version}/bundle.zip";
    hash = "sha256-kYUOJp1Pk0BpWPdeD7D0lNjY3PFc6eSjiyV7hJcpumo=";
  };

  buildPhase = ''
      mkdir -p $out/bin
  
      cp -r . $out/

      makeWrapper $out/glfos_welcome_screen $out/bin/glfos-welcome-screen \
      --set LD_LIBRARY_PATH "${lib.makeLibraryPath buildInputs}:$out/lib"

      mkdir -p $out/share/icons
      cp data/flutter_assets/assets/images/512x512.png $out/share/icons/glfos-welcome-screen.png

      mkdir -p $out/etc/xdg/autostart
      cp ${desktopFile}/share/applications/glfos-welcome-screen.desktop $out/etc/xdg/autostart/glfos-welcome-screen.desktop
      mkdir -p $out/share/applications
      cp ${desktopFile}/share/applications/glfos-welcome-screen.desktop $out/share/applications/glfos-welcome-screen.desktop
  '';
  
  meta = {
    description = "GLF-OS branding";
    homepage = "https://github.com/Gaming-Linux-FR/GLF-OS";
    license = lib.licenses.agpl3Plus;
  };

}
