{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.chirpstack;

  defaultPkg = pkgs.callPackage ../../pkgs/chirpstack-network-server/package.nix { };

  toml = pkgs.formats.toml { };

  # enabled_regions is derived from services.chirpstack.regions so that the
  # region ID only needs to be declared once.
  settings = lib.recursiveUpdate cfg.settings {
    network.enabled_regions = builtins.attrNames cfg.regions;
  };

  configFile = toml.generate "chirpstack.toml" settings;

  regionFiles = lib.mapAttrsToList (id: region: {
    name = "region_${id}.toml";

    path = toml.generate "region_${id}.toml" {
      regions = [
        (region // { inherit id; })
      ];
    };
  }) cfg.regions;

  # ChirpStack expects -c to point to a directory containing chirpstack.toml
  # together with all region_*.toml files.
  configDir = pkgs.linkFarm "chirpstack-config" (
    [
      {
        name = "chirpstack.toml";
        path = configFile;
      }
    ]
    ++ regionFiles
  );

  exec = lib.escapeShellArgs (
    [
      (lib.getExe cfg.package)
      "-c"
      "${configDir}"
    ]
    ++ cfg.extraArgs
  );
in
{
  options.services.chirpstack = {
    enable = lib.mkEnableOption "ChirpStack";

    package = lib.mkOption {
      type = lib.types.package;
      default = defaultPkg;
      description = "ChirpStack package.";
    };

    stateDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/chirpstack";
      description = "ChirpStack state directory.";
    };

    settings = lib.mkOption {
      type = toml.type;
      default = { };
      description = ''
        Main ChirpStack configuration.

        This is converted to chirpstack.toml. The network.enabled_regions
        option is generated automatically from services.chirpstack.regions.
      '';
    };

    regions = lib.mkOption {
      type = lib.types.attrsOf toml.type;
      default = { };
      description = ''
        ChirpStack region configurations.

        Each attribute creates a region_<id>.toml file. The attribute name
        is used as the region ID and is automatically added to
        network.enabled_regions.
      '';
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Additional ChirpStack command-line arguments.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open the ChirpStack API / web-interface port.";
    };

    uiPort = lib.mkOption {
      type = lib.types.port;
      default = 8080;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    users.groups.chirpstack = { };

    users.users.chirpstack = {
      isSystemUser = true;
      group = "chirpstack";
      home = cfg.stateDir;
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.stateDir} 0750 chirpstack chirpstack - -"
    ];

    # Persistent ChirpStack database.
    services.postgresql = {
      enable = true;

      ensureDatabases = [ "chirpstack" ];

      ensureUsers = [
        {
          name = "chirpstack";
          ensureDBOwnership = true;
        }
      ];
    };

    # ChirpStack requires pg_trgm. Append this after NixOS has created
    # the database and role.
    systemd.services.postgresql-setup.script = lib.mkAfter ''
      psql \
        --dbname=chirpstack \
        --command='CREATE EXTENSION IF NOT EXISTS pg_trgm;'
    '';

    # Metrics / cache backend. Local only.
    services.redis.servers.chirpstack = {
      enable = true;
      bind = "127.0.0.1";
      port = 6379;
      openFirewall = false;
    };

    systemd.services.chirpstack = {
      description = "ChirpStack";
      wantedBy = [ "multi-user.target" ];

      after = [
        "network-online.target"
        "mosquitto.service"
        "postgresql-setup.service"
        "redis-chirpstack.service"
      ];

      wants = [ "network-online.target" ];

      requires = [
        "mosquitto.service"
        "postgresql-setup.service"
        "redis-chirpstack.service"
      ];

      serviceConfig = {
        Type = "simple";

        User = "chirpstack";
        Group = "chirpstack";

        WorkingDirectory = cfg.stateDir;
        StateDirectory = "chirpstack";
        StateDirectoryMode = "0750";

        ExecStart = exec;

        Restart = "on-failure";
        RestartSec = 2;

        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "strict";

        ReadWritePaths = [ cfg.stateDir ];

        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];
      };
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.uiPort ];
  };
}
