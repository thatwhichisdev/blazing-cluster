{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.chirpstack-concentratord;

  configSource =
    if cfg.configFile != null then
      cfg.configFile
    else
      pkgs.writeText "concentratord.toml" cfg.configText;

  configPath = "${cfg.configDir}/concentratord.toml";

  exec = lib.escapeShellArgs (
    [
      (lib.getExe' cfg.package cfg.binaryName)
      "-c"
      configPath
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

    configDir = lib.mkOption {
      type = lib.types.str;
      default = "/etc/chirpstack-concentratord";
      description = "Directory containing concentratord.toml.";
    };

    configFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to concentratord.toml.";
    };

    configText = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Inline concentratord.toml used when configFile is null.";
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
      "d ${cfg.configDir} 0755 root root - -"
    ];

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

        ReadWritePaths = [
          cfg.stateDir
          "/run/chirpstack-concentratord"
        ];
      };
    };
  };
}
