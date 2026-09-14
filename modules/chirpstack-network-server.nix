_: {
  imports = [
    ./chirpstack/chirpstack.nix
  ];

  services.chirpstack = {
    enable = true;

    settings = {
      logging.level = "info";

      postgresql.dsn = "postgresql:///chirpstack?host=/run/postgresql";

      redis.servers = [
        "redis://127.0.0.1:6379/"
      ];

      network = {
        net_id = "000000";
      };

      api = {
        bind = "0.0.0.0:8080";
      };
    };

    regions.eu868 = {
      description = "EU868";
      common_name = "EU868";
    };
  };
}
