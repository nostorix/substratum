{ inputs, ... }: {
  flake = {
    lib = {
      mkNeovim =
        {
          pkgs,
          modules ? [ ],
        }:
        (inputs.nvf.lib.neovimConfiguration {
          inherit pkgs;
          modules = [
            (import ./_config.nix)
          ]
          ++ modules;
        }).neovim;
    };
  };
}
