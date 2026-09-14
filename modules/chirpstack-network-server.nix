_: {
  imports = [
    ./chirpstack/chirpstack.nix
  ];

  services.chirpstack = {
    enable = true;

    configFile = ./chirpstack-network-server/chirpstack.toml;

    regionFiles = [
      ./chirpstack-network-server/region_eu868.toml
    ];

    openFirewall = true;
  };
}
