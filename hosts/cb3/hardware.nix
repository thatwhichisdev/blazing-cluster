{ ... }:
{
  hardware.bluetooth.enable = false;
  hardware.raspberry-pi.config = {
    all = {
      options = {
        enable_uart = {
          enable = true;
          value = true;
        };
      };

      base-dt-params = {
        pciex1 = {
          enable = true;
          value = "on";
        };

        pciex1_gen = {
          enable = true;
          value = "2";
        };
      };
    };

    cm5 = {
      dt-overlays = {
        uart4-pi5 = {
          enable = true;
          params = { };
        };

        disable-bt-pi5 = {
          enable = true;
          params = { };
        };
      };

      base-dt-params = {
        uart4 = {
          enable = true;
          value = "on";
        };
      };
    };
  };
}
