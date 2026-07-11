{ lib, ... }:
{
  hardware.bluetooth.enable = false;
  hardware.raspberry-pi.config = {
    all = {
      options = {
        camera_auto_detect = {
          enable = false;
          value = false;
        };

        display_auto_detect = {
          enable = false;
          value = false;
        };

        enable_uart = {
          enable = true;
          value = true;
        };
      };

      dt-overlays = {
        uart5 = {
          enable = true;
          params = { };
        };

        disable-bt = {
          enable = true;
          params = { };
        };
      };

      base-dt-params = {
        audio = {
          enable = lib.mkForce false;
          value = "off";
        };

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
  };
}
