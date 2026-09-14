_: {
  imports = [
    ./chirpstack/concentratord.nix
  ];

  services.chirpstack-concentratord = {
    enable = true;

    settings = {
      concentratord = {
        log_level = "INFO";
        log_to_syslog = false;
        stats_interval = "30s";
        disable_crc_filter = false;

        api = {
          event_bind = "ipc:///run/chirpstack-concentratord/concentratord_event";
          command_bind = "ipc:///run/chirpstack-concentratord/concentratord_command";
        };
      };

      gateway = {
        antenna_gain = 0;
        lorawan_public = true;
        region = "EU868";

        model = "rak_2287";
        model_flags = [ "USB" ];

        time_fallback_enabled = true;

        concentrator = {
          multi_sf_channels = [
            868100000
            868300000
            868500000
            867100000
            867300000
            867500000
            867700000
            867900000
          ];

          lora_std = {
            frequency = 868300000;
            bandwidth = 250000;
            spreading_factor = 7;
          };

          fsk = {
            frequency = 868800000;
            bandwidth = 125000;
            datarate = 50000;
          };
        };

        location = {
          latitude = 0.0;
          longitude = 0.0;
          altitude = 0;
        };
      };
    };
  };
}
