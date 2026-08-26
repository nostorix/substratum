{ pkgs, ... }:
let
  pinnedElectron = pkgs.electron_43.override {
    electron-unwrapped = pkgs.electron_43.passthru.unwrapped.overrideAttrs (old: rec {
      version = "43.2.0";
      src = pkgs.fetchurl {
        url = "https://github.com/electron/electron/releases/download/v${version}/electron-v${version}-linux-x64.zip";
        hash = "sha256-93ym7We7xocCtptWrUmbymrgkHBa3n0E8KxUXkCd7Gg=";
      };
    });
  };
in
pkgs.vesktop.override {
  electron_43 = pinnedElectron;
}
