_: {
  imports = [
    ./chirpstack/mqtt-forwarder.nix
  ];

  services.chirpstack-mqtt-forwarder = {
    enable = true;
    configFile = ./chirpstack-mqtt-forwarder/mqtt-forwarder.toml;
  };
}
