{ pkgs, inputs', ... }:
let
  nixpkgsInput = inputs'.electron-nixpkgs.legacyPackages;
in
pkgs.vesktop.override {
  electron_43 = nixpkgsInput.electron_43;
}
