{
  pkgs,
  lib,
  config,
  ...
}:
{
  config.vim = {
    comments = {
      comment-nvim.enable = true;
    };
    autopairs = {
      nvim-autopairs.enable = true;
    };
    viAlias = false;
    vimAlias = true;
    undoFile.enable = true;
    preventJunkFiles = true;
    tabline.nvimBufferline.enable = true;

    utility = {
      new-file-template = {
        enable = true;
      };
    };

    keymaps = [
      {
        key = "<leader>e";
        mode = "n";
        silent = true;
        action = ":Neotree toggle reveal<CR>";
      }
      {
        key = "<leader>[";
        mode = "n";
        silent = true;
        action = "vim.fn.search('[([{<]', 'n')";
      }
      {
        key = "<leader>]";
        mode = "n";
        silent = true;
        action = "vim.fn.search('[([{<]', 'bn')";
      }
    ];

    options = {
      clipboard = "unnamedplus";
      ignorecase = true;
      mouse = "a";
      autoindent = true;
      smartindent = true;
      tabstop = 2;
      shiftwidth = 2;
      softtabstop = 2;
      expandtab = true;
      updatetime = 50;
    };

    extraPlugins = {
      log-highlight = {
        package = pkgs.vimUtils.buildVimPlugin {
          name = "log-highlight-nvim";
          src = pkgs.fetchFromGitHub {
            owner = "fei6409";
            repo = "log-highlight.nvim";
            rev = "ca88628f6dd3b9bb46f9a7401669e24cf7de47a4";
            sha256 = "sha256-s2GL6ddIA9wJI+K/irDtW7xvM/ms8it+04akr3ljJLA=";
          };
        };
      };
    };

    statusline.lualine.enable = true;
    telescope.enable = true;
    autocomplete.blink-cmp = {
      enable = true;
      setupOpts = {
        signature.enabled = true;
      };
    };
    treesitter.enable = true;
    visuals.fidget-nvim.enable = true;
    binds.whichKey.enable = true;
    filetree.neo-tree = {
      enable = true;
      setupOpts = {
        window = {
          position = "right";
        };
      };
    };
    diagnostics = {
      presets.eslint_d.enable = true;
      presets.stylelint.enable = true;
      enable = true;
      config = {
        update_in_insert = true;
        signs.text = lib.generators.mkLuaInline ''
          {
            [vim.diagnostic.severity.ERROR] = "󰅚 ",
            [vim.diagnostic.severity.WARN] = "󰀪 ",
          }
        '';
        virtual_text = {
          format = lib.generators.mkLuaInline ''
            function(diagnostic)
              return string.format("%s (%s)", diagnostic.message, diagnostic.source)
            end
          '';
        };
      };
    };
    lsp = {
      trouble.enable = true;
      formatOnSave = true;
      enable = true;
      lspconfig.enable = true;
      servers = {
        nixd = {
          settings = {
            nixd = {
              nixpkgs = {
                expr = "import <nixpkgs> { }";
              };
              options = {
                nvf = {
                  expr = ''((builtins.getFlake "github:NotAShelf/nvf").lib.neovimConfiguration {pkgs={};}).options'';
                };
                flake_parts = {
                  expr = ''
                    let
                        flakePath = ./.;
                        flake = if builtins.pathExists(flakePath+"/flake.nix")
                                then builtins.getFlake(toString flakePath)
                                else {};

                        debugOptions = 
                          if flake ? debug && flake.debug ? options
                          then flake.debug.options
                          else {};

                        systemOptions = 
                          if flake ? currentSystem && flake.currentSystem ? options
                          then flake.currentSystem.options
                          else {};
                      in
                        debugOptions // systemOptions
                  '';
                };
              };
            };
          };
        };
      };

    };
    languages = {
      enableTreesitter = true;
      clang = {
        enable = true;
        lsp = {
          enable = true;
        };
        cHeader = true;
        extraDiagnostics.enable = true;
        treesitter.enable = true;
      };
      ts = {
        enable = true;
        #lsp.servers = [];
      };
      nix = {
        enable = true;
        lsp.servers = [ "nixd" ];
      };
    };
  };
}
