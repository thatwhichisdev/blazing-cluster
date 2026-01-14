{ config, lib, pkgs, ... }:

let
  cfg = config.services.chirpstack-network-server;

  defaultPkg =
    pkgs.callPackage ../../pkgs/chirpstack-network-server/package.nix { };

  configDir = cfg.configDir;

  configSource = if cfg.configFile != null then
    cfg.configFile
  else
    pkgs.writeText "chirpstack.toml" cfg.configText;

  exec = lib.concatStringsSep " "
    ([ "${cfg.package}/bin/${cfg.binaryName}" "-c" configDir ]
      ++ cfg.extraArgs);
in {
  options.services.chirpstack-network-server = {
    enable =
      lib.mkEnableOption "ChirpStack Network Server (SQLite upstream binary)";

    package = lib.mkOption {
      type = lib.types.package;
      default = defaultPkg;
      description = "Package providing the ChirpStack server binary.";
    };

    binaryName = lib.mkOption {
      type = lib.types.str;
      default = "chirpstack-network-server";
      description = "Binary name inside the package's /bin.";
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
      default = "/var/lib/chirpstack";
      description = "Writable state directory (SQLite db, etc).";
    };

    configDir = lib.mkOption {
      type = lib.types.str;
      default = "/etc/chirpstack";
      description =
        "Directory passed to ChirpStack via -c. Must contain chirpstack.toml.";
    };

    configFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description =
        "Path to a chirpstack.toml file to install into /etc/chirpstack/chirpstack.toml.";
    };

    regionFiles = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      default = [ ];
      description = ''
        List of region_*.toml files (e.g. region_eu868.toml) to be installed
        alongside chirpstack.toml in the configDir.
      '';
    };

    configText = lib.mkOption {
      type = lib.types.lines;
      default = ''
        # Provide TOML via services.chirpstack-network-server.configFile
        # or override this text.
      '';
      description =
        "Inline chirpstack.toml content used when configFile is null.";
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Extra CLI args passed to the chirpstack binary.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open uiPort in the firewall (TCP).";
    };

    uiPort = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description =
        "Port to open when openFirewall=true. Must match your TOML bind.";
    };
  };

  config = lib.mkIf cfg.enable {

    # Create user/group
    users.groups.${cfg.group} = { };
    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
      home = cfg.stateDir;
      createHome = true;
    };

    # Ensure dirs exist with sane perms
    systemd.tmpfiles.rules = [
      "d ${cfg.stateDir} 0750 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.configDir} 0755 root root - -"
    ];

    # Install region_*.toml files next to chirpstack.toml
    environment.etc = lib.mkMerge ([{
      "chirpstack/chirpstack.toml" = {
        source = configSource;
        mode = "0644";
      };
    }] ++ map (regionFile:
      let name = builtins.baseNameOf regionFile;
      in {
        "chirpstack/${name}" = {
          source = regionFile;
          mode = "0644";
        };
      }) cfg.regionFiles);

    # Service
    systemd.services.chirpstack-network-server = {
      description = "ChirpStack Network Server (SQLite)";
      wantedBy = [ "multi-user.target" ];

      # Wait for network + deps
      after = [ "network-online.target" "mosquitto.service" "redis.service" ];
      wants = [ "network-online.target" "mosquitto.service" "redis.service" ];

      # If you use a non-default redis unit name (e.g. redis-foo.service),
      # change these. Minimal version assumes redis.service.
      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;

        WorkingDirectory = cfg.stateDir;
        StateDirectory = "chirpstack";
        # (StateDirectory creates /var/lib/chirpstack *only* if it's under /var/lib,
        # but we already do tmpfiles; leaving it doesn't hurt.)

        ExecStart = exec;

        Restart = "on-failure";
        RestartSec = 2;

        # mild hardening without breaking sqlite writes
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        ReadWritePaths = [ cfg.stateDir ];
      };
    };

    # Firewall (optional)
    networking.firewall.allowedTCPPorts =
      lib.mkIf cfg.openFirewall [ cfg.uiPort ];
  };
}
