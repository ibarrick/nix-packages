{ lib
, stdenv
, fetchurl
, makeWrapper
, jre
, gtk3
, glib
, libXtst
, webkitgtk
, patchelf
, autoPatchelfHook
, alsa-lib
, xorg
, gsettings-desktop-schemas
}:

stdenv.mkDerivation rec {
  pname = "jaspersoft-studio";
  version = "7.0.0";

  src = fetchurl {
    url = "https://esterwind-public.s3.amazonaws.com/js-studiocomm_7.0.0_linux_x86_64.tgz";
    hash = "sha256-5cDVWR7M8mQidjSX6UzZZqMeex9+1FHJxisJcZz/lfg=";
  };

  nativeBuildInputs = [ makeWrapper patchelf autoPatchelfHook ];

  buildInputs = [
    jre
    gtk3
    glib
    libXtst
    webkitgtk
    alsa-lib
    xorg.xorgserver
    gsettings-desktop-schemas
  ];

  installPhase = ''
    mkdir -p $out/lib/jaspersoft-studio
    cp -r . $out/lib/jaspersoft-studio

    chmod +x $out/lib/jaspersoft-studio/Jaspersoft\ Studio

    mkdir -p $out/bin
    makeWrapper $out/lib/jaspersoft-studio/Jaspersoft\ Studio \
      $out/bin/.jaspersoft-studio-wrapped \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs} \
      --set JAVA_HOME ${jre} \
      --set XDG_DATA_DIRS "${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}:${gtk3}/share/gsettings-schemas/${gtk3.name}:$XDG_DATA_DIRS" \
      --prefix GIO_EXTRA_MODULES : "${glib.out}/lib/gio/modules"

    # Create a wrapper script to force XWayland and set up GSettings
    cat > $out/bin/jaspersoft-studio <<EOF
    #!/bin/sh
    export GDK_BACKEND=x11
    export NIXOS_OZONE_WL=0
    # Ensure GSettings schemas are compiled
    glib-compile-schemas ${gsettings-desktop-schemas}/share/glib-2.0/schemas
    exec $out/bin/.jaspersoft-studio-wrapped "\$@"
    EOF

    chmod +x $out/bin/jaspersoft-studio
  '';

  dontAutoPatchelf = false;

  meta = with lib; {
    description = "Eclipse-based report development tool for JasperReports";
    homepage = "https://community.jaspersoft.com/project/jaspersoft-studio";
    license = licenses.epl10;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ /* your-name */ ];
  };
}
