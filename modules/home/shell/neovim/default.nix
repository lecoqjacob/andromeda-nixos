{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.milkyway) mkEnableOpt;

  cfg = config.milkyway.shell.neovim;
in {
  options.milkyway.shell.neovim = mkEnableOpt "Neovim";

  config = mkIf cfg.enable {
    # Use Neovim for Git diffs.
    programs = {
      zsh.shellAliases.vimdiff = "nvim -d";
      bash.shellAliases.vimdiff = "nvim -d";
    };

    home = {
      packages = with pkgs; [
        neovim
        vim

        # Needed for neovim
        gcc
        gnumake
        luajitPackages.luarocks-nix
        nodejs_18
        sqlite
      ];

      sessionVariables = {
        PAGER = "bat";
        EDITOR = "nvim";
        MANPAGER = "bat";
      };

      shellAliases = {
        vimdiff = "nvim -d";
      };
    };
  };
}
