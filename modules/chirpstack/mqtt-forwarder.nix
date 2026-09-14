{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.chirpstack-mqtt-forwarder;

  toml = pkgs.formats.toml { };
  configFile = toml.generate "chirpstack-mqtt-forwarder.toml" cfg.settings;

  exec = lib.escapeShellArgs (
    [
      (lib.getExe cfg.package)
      "-c"
      "${configFile}"
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

    settings = lib.mkOption {
      type = toml.type;
      default = { };
      description = "ChirpStack MQTT Forwarder configuration.";
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
