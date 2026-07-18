{ self, inputs, ... }: {
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
            self.nvf.config
          ]
          ++ modules;
        }).neovim;
    };
  };
}
