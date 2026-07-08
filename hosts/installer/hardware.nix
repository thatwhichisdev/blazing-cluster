{ lib, ... }:
{
  hardware.bluetooth.enable = lib.mkForce false;
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
          value = "3";
        };
      };
    };
  };
}
