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
        uart4 = {
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

    cm5 = {
      options = {
        # nixos-raspberrypi enables this by default.
        # Disable it to remove any board/firmware boost behaviour.
        arm_boost = {
          enable = true;
          value = false;
        };

        # Prevent firmware from holding turbo during early boot.
        initial_turbo = {
          enable = true;
          value = 0;
        };
      };
    };
  };
}
