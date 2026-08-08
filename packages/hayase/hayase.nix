{
  lib,
  appimageTools,
  fetchurl,
  pkgs,
  forceX11 ? false,
  ...
}:
let
  pname = "hayase";
  version = "6.4.79";

  src = fetchurl {
    url = "https://api.hayase.watch/files/linux-hayase-${version}-linux.AppImage";
    hash = "sha256-s3+t5slPz6qNZ60FDyWMR/LJSYvFI3BmZtoOUPGEZm8=";
  };
  contents = appimageTools.extractType2 {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;
  extraInstallCommands = ''
    mkdir -p $out/share/applications
    mkdir -p "$out/share/lib/hayase"
    cp -r ${contents}/{locales,resources} "$out/share/lib/hayase"
    cp -r ${contents}/usr/* "$out"
    cp ${contents}/hayase.desktop $out/share/applications/
    substituteInPlace $out/share/applications/hayase.desktop \
      --replace-fail 'Exec=AppRun' 'Exec=hayase${lib.optionalString forceX11 " --ozone-platform=x11"}'
  '';
  meta = with lib; {
    description = "Stream your torrents real-time, witout waiting for downloads.";
    longDescription = "Hayase is a bring-your-own-content application. It does not ship or link unofficial libraries, it simply lets you organise and watch media you already have permission to access.";
    homepage = "https://hayase.watch";
    license = licenses.bsl11;
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
    platforms = platforms.linux;
    mainProgram = "hayase";
  };
}
