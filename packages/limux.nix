{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  wrapGAppsHook4,
  gtk4,
  libadwaita,
  webkitgtk_6_0,
  glib,
  pango,
  fontconfig,
  gcc,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "limux";
  version = "0.1.21";

  src = fetchurl {
    url = "https://github.com/am-will/limux/releases/download/v${finalAttrs.version}/limux-${finalAttrs.version}-linux-x86_64.tar.gz";
    hash = "sha256-vt+hsiQWP5IxDQ/htlEKMOt/seppFBkoyz2AwieFBlE=";
  };

  sourceRoot = "limux-${finalAttrs.version}-linux-x86_64";

  nativeBuildInputs = [
    autoPatchelfHook
    wrapGAppsHook4
  ];

  buildInputs = [
    fontconfig
    gcc.cc.lib
    glib
    gtk4
    libadwaita
    pango
    webkitgtk_6_0
  ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 limux "$out/bin/limux"
    install -Dm755 libexec/limux/limux-host "$out/libexec/limux/limux-host"
    install -Dm755 lib/libghostty.so "$out/lib/libghostty.so"
    cp -r share "$out/share"

    runHook postInstall
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix LD_LIBRARY_PATH : "$out/lib"
      --prefix XDG_DATA_DIRS : "$out/share"
      --prefix TERMINFO_DIRS : "$out/share/limux/terminfo"
    )
  '';

  meta = with lib; {
    description = "GPU-accelerated terminal workspace manager for Linux";
    homepage = "https://github.com/am-will/limux";
    changelog = "https://github.com/am-will/limux/releases/tag/v${finalAttrs.version}";
    license = licenses.mit;
    mainProgram = "limux";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
})
