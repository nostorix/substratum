{
  description = "My personal package collection - Substratum";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    import-tree.url = "github:vic/import-tree";

    electron-nixpkgs.url = "github:NixOS/nixpkgs/f82dc8ebe9d6e4c3bd65ab162d62ba566f39066c";

    nvf = {
      url = "github:NotAShelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ ... }:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      debug = true;
      imports = [
        {
          perSystem = { pkgs, ... }: {
            formatter = pkgs.nixfmt-tree;
          };
        }
        (inputs.import-tree ./modules)
      ];
    };
}
