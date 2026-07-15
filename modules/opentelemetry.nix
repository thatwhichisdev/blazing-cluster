{
  config,
  lib,
  pkgs,
  ...
}:
{
  age.secrets.opentelemetry = {
    file = ../secrets/opentelemetry.age;
    name = "opentelemetry.yaml";
    owner = "root";
    group = "root";
    mode = "0400";
  };

  services.opentelemetry-collector = {
    enable = true;
    package = pkgs.opentelemetry-collector-contrib;
    configFile = config.age.secrets.opentelemetry.path;
    validateConfigFile = false;
  };

  systemd.services.opentelemetry-collector = {
    environment = {
      OTEL_RESOURCE_ATTRIBUTES = lib.concatStringsSep "," [
        "host.name=${config.networking.hostName}"
        "service.name=${config.networking.hostName}"
        "service.namespace=blazing-cluster"
        "deployment.environment.name=homelab"
      ];
    };

    path = [
      pkgs.systemd
    ];

    restartTriggers = [
      config.age.secrets.opentelemetry.file
    ];

    serviceConfig = {
      DynamicUser = lib.mkForce false;
      User = "root";
      Group = "root";

      ExecStartPre = [
        "${lib.getExe pkgs.opentelemetry-collector-contrib} validate --config=file:${config.age.secrets.opentelemetry.path}"
      ];

      StateDirectoryMode = "0700";
    };
  };
}
