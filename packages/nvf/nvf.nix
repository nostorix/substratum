{ self, pkgs, ... }:
self.lib.mkNeovim { inherit pkgs; }
