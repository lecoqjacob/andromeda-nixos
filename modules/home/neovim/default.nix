{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.milkyway.apps.neovim;
  # coreImports = lib.andromeda.fs.get-nix-files ./core;
in {
  # imports = coreImports;

  options.milkyway.apps.neovim = {
    enable = mkEnableOption "Neovim";
  };

  config = mkIf cfg.enable {
    # Use Neovim for Git diffs.
    programs = {
      zsh.shellAliases.vimdiff = "nvim -d";
      bash.shellAliases.vimdiff = "nvim -d";
    };

    home = {
      packages = with pkgs; [
        vim
        neovim

        # Needed for neovim
        gcc
        gnumake
        nodejs_18
        unzip

        lua54Packages.lua
        lua54Packages.inspect
        lua54Packages.luarocks

        #Rust
        toolchain
        rust-analyzer-nightly
      ];

      sessionVariables = {
        EDITOR = "nvim";
      };

      shellAliases = {
        vimdiff = "nvim -d";
      };
    };

    xdg.configFile = {
      # Configurations
      "nvim/.luacheckrc".source = ./config/.luacheckrc;
      "nvim/.stylua.toml".source = ./config/.stylua.toml;
      "nvim/.neoconf.json".source = ./config/.neoconf.json;

      # Our bread and butter
      "nvim/init.lua".text = ''
        -- bootstrap lazy.nvim; AstroNvim; and user plugins
        require("config.lazy")

        -- run polish file at the very end
        pcall(require, "config.polish")
      '';
    };

    milkyway.apps.neovim = {
      plugins = {
        astrocore = {
          autocmds = {
            highlighturl = {
              desc = "URL Highlighting";
              event = ["VimEnter" "FileType" "BufEnter" "WinEnter"];
              callback = ''function() require("astrocore").set_url_match() end'';
            };
          };

          commands = {
            AstroReload = {
              desc = "Reload AstroNvim (Experimental)";
              action = ''function() require("astrocore").reload() end'';
            };
          };

          mappings = {
            n = {
              "<C-s>" = {
                action = ":w!<cr>";
                desc = "Save File";
              };

              "<C-q>" = {
                action = ":q!<cr>";
                desc = "quit File";
              };

              "L" = {
                desc = "Next buffer";
                action = ''function() require("astronvim.utils.buffer").nav(vim.v.count > 0 and vim.v.count or 1) end'';
              };
            };
          };

          on_keys = {
            auto_hlsearch = [
              ''
                function(char) -- example automatically disables `hlsearch` when not actively searching
                  if vim.fn.mode() == "n" then
                    local new_hlsearch = vim.tbl_contains({ "<CR>"; "n"; "N"; "*"; "#"; "?"; "/" }, vim.fn.keytrans(char))
                    if vim.opt.hlsearch:get() ~= new_hlsearch then vim.opt.hlsearch = new_hlsearch end
                  end
                end;
              ''
            ];
          };

          git_worktrees = [
            {
              toplevel = ''vim.env.HOME'';
              gitdir = ''vim.env.HOME .. " /.dotfiles "'';
            }
          ];
        };

        astroui = {
          colorscheme = "astrodark";

          # highlights = {
          #   init = {
          #     Normal = {
          #       bg = "#FF0000";
          #     };
          #   };
          # };

          icons = {
            GitAdd = "";
          };
          text_icons = {
            GitAdd = "[+]";
          };

          status = {
            attributes = {
              git_branch = {bold = true;};
            };

            colors = {
              git_branch_fg = "#ABCDEF";
            };

            icon_highlights = {
              breadcrumbs = false;

              file_icon = {
                statusline = true;
                tabline = ''function(self) return self.is_active or self.is_visible end'';
              };
            };

            separators = {
              none = ["" ""];
              tab = ["" ""];
              breadcrumbs = "  ";
            };
          };
        };

        astrolsp = {
          # features = {
          #   codelens = true;
          #   autoformat = true;
          #   inlay_hints = false;
          #   lsp_handlers = true;
          #   diagnostics_mode = 3;
          #   semantic_tokens = true;
          # };

          # capabilities = {
          #   textDocument = {
          #     foldingRange = {dynamicRegistration = false;};
          #   };
          # };

          # config = {
          #   lua_ls = {
          #     settings = {
          #       Lua = {
          #         hint = {
          #           enable = true;
          #           arrayIndex = "Disable";
          #         };
          #       };
          #     };
          #   };
          #   clangd = {
          #     capabilities = {
          #       offsetEncoding = "utf-8";
          #     };
          #   };
          # };

          # diagnostics = {
          #   update_in_insert = false;
          # };

          # flags = {
          #   exit_timeout = 5000;
          # };

          # formatting = {
          #   format_on_save = {
          #     enabled = true;

          #     allow_filetypes = [
          #       "go"
          #     ];

          #     ignore_filetypes = [
          #       "python"
          #     ];
          #   };

          #   disabled = [
          #     "lua_ls"
          #   ];

          #   timeout_ms = 1000;

          #   filter = ''
          #     function(client)
          #       return true
          #     end
          #   '';
          # };

          # handlers = {
          #   default = ''
          #     function(server, opts)
          #       require("lspconfig")[server].setup(opts)
          #     end
          #   '';

          #   pyright = ''
          #     function(_, opts)
          #       require("lspconfig").pyright.setup(opts)
          #     end
          #   '';

          #   rust_analyzer = false;
          # };

          # mappings = {
          #   n = [
          #     {
          #       key = "gl";
          #       action = "function() vim.diagnostic.open_float() end";
          #       desc = "Hover diagnostics";
          #     }
          #   ];
          # };

          mappings = {
            n = {
              gl = {
                lua = true;
                action = "function() vim.diagnostic.open_float() end";
                desc = "Hover diagnostics";
              };
            };
          };
        };
      };
    };
  };
}
