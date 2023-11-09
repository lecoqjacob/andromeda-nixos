{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
with lib.milkyway; let
  cfg = config.milkyway.security.gpg;
  cfgAgent = config.milkyway.security.gpg-agent;

  pinentry = {
    name = "gnome3";
    package = pkgs.pinentry-gnome;
    packages = with pkgs; [
      pinentry-gnome
      pinentry-curses
    ];
  };

  gpgConf = "${get-source "gpg-base-conf"}/gpg.conf";
  gpgAgentConf = ''
    enable-ssh-support
    default-cache-ttl 60
    max-cache-ttl 120
    pinentry-program ${pinentry.package}/bin/pinentry-${pinentry.name}
  '';
in {
  options.milkyway.security = {
    gpg = with types; {
      enable = mkEnableOption "Whether or not to enable GPG.";
      agentTimeout = mkOpt int 5 "The amount of time to wait before continuing with shell init.";
    };

    gpg-agent = {
      enable = mkBoolOpt true "Whether or not to enable GPG Agent.";
      enableSSHSupport = mkBoolOpt true "Whether or not to enable SSH Support.";
      enableExtraSocket = mkBoolOpt false "Whether or not to enable the extra socket.";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      environment.systemPackages = with pkgs;
        [
          gcr
          gnupg
        ]
        ++ pinentry.packages;

      services = {
        pcscd.enable = true;
        udev.packages = with pkgs; [yubikey-personalization];
      };

      milkyway.home.file = {
        ".gnupg/.keep".text = "";
        ".gnupg/gpg.conf".source = gpgConf;
      };
    }

    (mkIf cfgAgent.enable {
      programs = {
        ssh.startAgent = false;

        gnupg.agent = mkIf cfgAgent.enable {
          enable = true;
          pinentryFlavor = pinentry.name;
          inherit (cfgAgent) enableExtraSocket enableSSHSupport;
        };
      };

      environment = {
        # *NOTE(lecoqjacob): This should already have been added by programs.gpg, but
        # *keeping it here for now just in case.
        shellInit = ''
          export GPG_TTY="$(tty)"
          export SSH_AUTH_SOCK=$(${pkgs.gnupg}/bin/gpgconf --list-dirs agent-ssh-socket)

          ${pkgs.coreutils}/bin/timeout ${builtins.toString cfg.agentTimeout} ${pkgs.gnupg}/bin/gpgconf --launch gpg-agent
          gpg_agent_timeout_status=$?

          if [ "$gpg_agent_timeout_status" = 124 ]; then
            # Command timed out...
            echo "GPG Agent timed out..."
            echo 'Run "gpgconf --launch gpg-agent" to try and launch it again.'
          fi
        '';
      };
      milkyway.home.file = {
        ".gnupg/gpg-agent.conf".text = gpgAgentConf;
      };
    })
  ]);
}
