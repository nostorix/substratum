{ self, inputs, ... }:

{
  perSystem =
    {
      pkgs,
      lib,
      system,
      self',
      ...
    }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      packages =
        let
          tree = (inputs.import-tree.new.addPath ../packages).leafs.withLib lib;
        in
        lib.listToAttrs (
          map (file: {
            name = lib.removeSuffix ".nix" (baseNameOf file);
            value = pkgs.callPackage file { inherit self; };
          }) tree.result
        );

      apps = lib.mapAttrs (name: pkg: {
        type = "app";
        program = if pkg ? meta.mainProgram then lib.getExe pkg else lib.getExe' pkg name;
      }) self'.packages;

    };
}
