{ inputs, ... }:
{
  imports = [
    inputs.blazing-fan.nixosModules.default
  ];

  services.blazing-fan-daemon = {
    enable = true;
  };
}
