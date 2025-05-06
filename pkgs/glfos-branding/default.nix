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
      mkdir -p $out/share/backgrounds/gnome
      cp $src/wallpaper/leather-glf.png $out/share/backgrounds/gnome/leather-glf.png
      cp $src/wallpaper/dalle-glf.png $out/share/backgrounds/gnome/dalle-glf.png
      cp $src/wallpaper/vintage-glf.png $out/share/backgrounds/gnome/vintage-glf.png
      cp $src/wallpaper/dark.jpg $out/share/backgrounds/gnome/dark.jpg
      cp $src/wallpaper/white.jpg $out/share/backgrounds/gnome/white.jpg

      mkdir -p $out/share/gnome-background-properties/
                  cat <<EOF > $out/share/gnome-background-properties/leather-glf.xml
<?xml version="1.0" encoding="UTF-8"?>
   <!DOCTYPE wallpapers SYSTEM "gnome-wp-list.dtd">
   <wallpapers>
   <wallpaper deleted="false">
      <name>leather-glf</name>
      <filename>/run/current-system/sw/share/backgrounds/gnome/leather-glf.png</filename>
      <options>zoom</options>
      <shade_type>solid</shade_type>
      <pcolor>#ffffff</pcolor>
      <scolor>#000000</scolor>
     </wallpaper>
    </wallpapers>

EOF

                  cat <<EOF > $out/share/gnome-background-properties/vintage-glf.xml
<?xml version="1.0" encoding="UTF-8"?>
   <!DOCTYPE wallpapers SYSTEM "gnome-wp-list.dtd">
   <wallpapers>
   <wallpaper deleted="false">
      <name>vintage-glf</name>
      <filename>/run/current-system/sw/share/backgrounds/gnome/vintage-glf.png</filename>
      <options>zoom</options>
      <shade_type>solid</shade_type>
      <pcolor>#ffffff</pcolor>
      <scolor>#000000</scolor>
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
