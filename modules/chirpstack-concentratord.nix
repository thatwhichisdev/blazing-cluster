_: {
  imports = [
    ./chirpstack/concentratord.nix
  ];

  services.chirpstack-concentratord = {
    enable = true;
    configFile = ./chirpstack-concentratord/concentratord.toml;
  };
}
