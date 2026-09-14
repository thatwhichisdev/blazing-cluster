{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.chirpstack-concentratord;

  toml = pkgs.formats.toml { };
  configFile = toml.generate "concentratord.toml" cfg.settings;

  exec = lib.escapeShellArgs (
    [
      (lib.getExe' cfg.package cfg.binaryName)
      "-c"
      "${configFile}"
    ]
    ++ cfg.extraArgs
  );
in
{
  options.services.chirpstack-concentratord = {
    enable = lib.mkEnableOption "ChirpStack Concentratord";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.chirpstack-concentratord;
      defaultText = lib.literalExpression "pkgs.chirpstack-concentratord";
      description = "Package providing ChirpStack Concentratord.";
    };

    binaryName = lib.mkOption {
      type = lib.types.str;
      default = "chirpstack-concentratord-sx1302";
      description = "Concentratord binary to run.";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "chirpstack";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "chirpstack";
    };

    stateDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/chirpstack-concentratord";
      description = "Writable state directory.";
    };

    settings = lib.mkOption {
      type = toml.type;
      default = { };
      description = "ChirpStack Concentratord configuration.";
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Additional command-line arguments.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      cfg.package
    ];

    users.groups.${cfg.group} = { };

    users.users.${cfg.user} = {
      isSystemUser = true;
      inherit (cfg) group;
      home = cfg.stateDir;
      createHome = true;
      extraGroups = [ "dialout" ];
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.stateDir} 0750 ${cfg.user} ${cfg.group} - -"
    ];

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

        ReadWritePaths = [
          cfg.stateDir
          "/run/chirpstack-concentratord"
        ];
      };
    };
  };
}
