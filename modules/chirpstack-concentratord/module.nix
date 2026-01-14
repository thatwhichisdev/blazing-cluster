{ config, lib, pkgs, ... }:

let
  cfg = config.services.chirpstack-concentratord;

  defaultPkg =
    pkgs.callPackage ../../pkgs/chirpstack-concentratord/package.nix { };

  configDir = cfg.configDir;
  configSource = if cfg.configFile != null then
    cfg.configFile
  else
    pkgs.writeText "concentratord.toml" cfg.configText;

  exec = lib.concatStringsSep " " ([
    "${cfg.package}/bin/${cfg.binaryName}"
    "-c"
    "${configDir}/concentratord.toml"
  ] ++ cfg.extraArgs);
in {
  options.services.chirpstack-concentratord = {
    enable = lib.mkEnableOption "ChirpStack Concentratord";

    package = lib.mkOption {
      type = lib.types.package;
      default = defaultPkg;
      description = "Package providing chirpstack-concentratord.";
    };

    binaryName = lib.mkOption {
      type = lib.types.str;
      default = "chirpstack-concentratord-sx1302";
      description = "Binary name inside the package /bin.";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "chirpstack-concentratord";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = "chirpstack";
    };

    stateDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/chirpstack-concentratord";
      description =
        "Writable state directory (logs/runtime files if configured).";
    };

    configDir = lib.mkOption {
      type = lib.types.str;
      default = "/etc/chirpstack-concentratord";
      description = "Directory containing concentratord.toml.";
    };

    configFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to concentratord.toml to install into configDir.";
    };

    configText = lib.mkOption {
      type = lib.types.lines;
      default = ''
        # Provide TOML via services.chirpstack-concentratord.configFile
        # or override this inline TOML.
      '';
      description =
        "Inline concentratord.toml content used when configFile is null.";
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Extra CLI args passed to chirpstack-concentratord.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.groups.${cfg.group} = { };
    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
      home = cfg.stateDir;
      createHome = true;
      extraGroups = [ "dialout" ];
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.stateDir} 0750 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.configDir} 0755 root root - -"
    ];

    # Install /etc/chirpstack-concentratord/concentratord.toml
    environment.etc."chirpstack-concentratord/concentratord.toml" = {
      source = configSource;
      mode = "0644";
    };

    systemd.services.chirpstack-concentratord = {
      description = "ChirpStack Concentratord";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = cfg.stateDir;
        RuntimeDirectory = "chirpstack-concentratord";
        RuntimeDirectoryMode = "0775";
        UMask = "0002";
        ExecStart = exec;

        Restart = "on-failure";
        RestartSec = 2;

        NoNewPrivileges = true;
        ProtectSystem = "no";
        ReadWritePaths = [ cfg.stateDir "/run/chirpstack-concentratord" ];
      };
    };
  };
}
