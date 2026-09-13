{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.chirpstack-mqtt-forwarder;

  configSource =
    if cfg.configFile != null then
      cfg.configFile
    else
      pkgs.writeText "chirpstack-mqtt-forwarder.toml" cfg.configText;

  configPath = "${cfg.configDir}/chirpstack-mqtt-forwarder.toml";

  exec = lib.escapeShellArgs (
    [
      (lib.getExe cfg.package)
      "-c"
      configPath
    ]
    ++ cfg.extraArgs
  );
in
{
  options.services.chirpstack-mqtt-forwarder = {
    enable = lib.mkEnableOption "ChirpStack MQTT Forwarder";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.chirpstack-mqtt-forwarder;
      defaultText = lib.literalExpression "pkgs.chirpstack-mqtt-forwarder";
      description = "Package providing ChirpStack MQTT Forwarder.";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "chirpstack";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "chirpstack";
    };

    configDir = lib.mkOption {
      type = lib.types.str;
      default = "/etc/chirpstack-mqtt-forwarder";
      description = "Directory containing chirpstack-mqtt-forwarder.toml.";
    };

    configFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to chirpstack-mqtt-forwarder.toml.";
    };

    configText = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Inline configuration used when configFile is null.";
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Additional command-line arguments.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    users.groups.${cfg.group} = { };

    users.users.${cfg.user} = {
      isSystemUser = true;
      inherit (cfg) group;
    };

    environment.etc."chirpstack-mqtt-forwarder/chirpstack-mqtt-forwarder.toml" = {
      source = configSource;
      mode = "0644";
    };

    systemd.services.chirpstack-mqtt-forwarder = {
      description = "ChirpStack MQTT Forwarder";
      wantedBy = [ "multi-user.target" ];

      after = [
        "network-online.target"
        "chirpstack-concentratord.service"
      ];

      wants = [ "network-online.target" ];
      requires = [ "chirpstack-concentratord.service" ];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;

        ExecStart = exec;

        Restart = "on-failure";
        RestartSec = 2;

        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "strict";

        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];
      };
    };
  };
}
