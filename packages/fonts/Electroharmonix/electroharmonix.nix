{ pkgs, ... }:

pkgs.stdenvNoCC.mkDerivation {
  pname = "electroharmonix";
  version = "1.0";

  src = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/Keyitdev/sddm-astronaut-theme/c9a8ab46aea6f1bab39f1a9d8cd3178f6e89b745/Fonts/Electroharmonix.otf";
    hash = "sha256-P/G4ijTGlu1q9xk1wPvy4AjHJ+06vJP25yr5CTOgoC4=";
  };

  dontUnpack = true;

  installPhase = ''
    install -Dm644 $src $out/share/fonts/opentype/Electroharmonix.otf
  '';

  meta = with pkgs.lib; {
    description = "Electroharmonix custom font";
    platforms = platforms.all;
  };
}
