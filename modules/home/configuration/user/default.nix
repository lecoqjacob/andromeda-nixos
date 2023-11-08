{
  lib,
  pkgs,
  inputs,
  config,
  ...
}: let
  inherit (lib) types mkIf mkDefault;
  inherit (lib.milkyway) mkOpt;

  cfg = config.milkyway.user;
  is-darwin = pkgs.stdenv.isDarwin;

  home-directory =
    if cfg.name == null
    then null
    else if is-darwin
    then "/Users/${cfg.name}"
    else "/home/${cfg.name}";
in {
  imports = [
    ./home.nix
  ];

  options.milkyway.user = {
    enable = mkOpt types.bool false "Whether to configure the user account.";

    stateVersion = mkOpt types.str "23.11" "The state version to use for the user account.";
    name = mkOpt (types.nullOr types.str) config.andromeda.user.name "The user account.";

    fullName = mkOpt types.str "Jacob LeCoq" "The full name of the user.";
    email = mkOpt types.str "lecoqjacob@gmail.com" "The email of the user.";
    home = mkOpt (types.nullOr types.str) home-directory "The user's home directory.";
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.name != null;
        message = "milkyway.user.name must be set";
      }
      {
        assertion = cfg.home != null;
        message = "milkyway.user.home must be set";
      }
    ];

    home = {
      username = mkDefault cfg.name;
      homeDirectory = mkDefault cfg.home;
      stateVersion = mkDefault cfg.stateVersion;

      sessionVariables = {
        FLAKE = "${inputs.self.outPath}";
      };
    };

    systemd.user.startServices = "sd-switch";
  };
}