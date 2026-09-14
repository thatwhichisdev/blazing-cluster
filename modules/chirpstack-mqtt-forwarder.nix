_: {
  imports = [
    ./chirpstack/mqtt-forwarder.nix
  ];

  services.chirpstack-mqtt-forwarder = {
    enable = true;

    settings = {
      logging = {
        level = "info";
        log_to_syslog = false;
      };

      mqtt = {
        topic_prefix = "eu868";
        json = false;
        server = "tcp://192.168.0.159:1883";
        keep_alive_interval = "30s";
      };

      backend = {
        enabled = "concentratord";

        concentratord = {
          event_url = "ipc:///run/chirpstack-concentratord/concentratord_event";
          command_url = "ipc:///run/chirpstack-concentratord/concentratord_command";
        };
      };
    };
  };
}
