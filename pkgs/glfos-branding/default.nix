{ 
  lib,
  stdenvNoCC, 
  coreutils,
  bash, 
}:

stdenvNoCC.mkDerivation rec {
  pname = "glfos-branding";
  version = "1.0.0"; ### To update version number

  src = ../../assets;
  
  buildInputs = [ bash coreutils ];

  installPhase = ''
    # Logo

    for SIZE in 16 32 48 64 128 256; do
      mkdir -p $out/share/icons/hicolor/''${SIZE}x''${SIZE}/emblems
      cp $src/logo/logo-$SIZE.png $out/share/icons/hicolor/''${SIZE}x''${SIZE}/emblems/glfos-logo.png
      cp $src/logo/logo_light-$SIZE.png $out/share/icons/hicolor/''${SIZE}x''${SIZE}/emblems/glfos-logo-light.png
      
    done
  
    #wallpaper
      mkdir -p $out/share/backgrounds/glf
      cp $src/wallpaper/leather-glf.png $out/share/backgrounds/glf/leather-glf.png

cat <<EOF > $out/share/gnome-background-properties/leather-glf.xml
<?xml version="1.0"?>
<!DOCTYPE wallpapers SYSTEM "gnome-wp-list.dtd">
<wallpapers>
<wallpaper deleted="false">
<name>Leather-glf</name>
<filename>/run/current-system/sw/share/backgrounds/glf/leather-glf.png</filename>
<filename-dark>/run/current-system/sw/share/backgrounds/glf/leather-glf.png</filename-dark>
<options>zoom</options>
<shade_type>solid</shade_type>
<pcolor>#3a4ba0</pcolor>
<scolor>#2f302f</scolor>
</wallpaper>
</wallpapers>
EOF      
  '';

  meta = {
    description = "GLF-OS branding";
    homepage = "https://github.com/Gaming-Linux-FR/GLF-OS";
    license = lib.licenses.agpl3Plus;
  };

}
