{
  config,
  lib,
  modulesPath,
  inputs,
  ...
}:
{
  imports = [
    ../../modules/nix.nix
    inputs.nixos-images.nixosModules.sdimage-installer
  ];

  disabledModules = [
    # Disable the standard nixos-images aarch64 installer module.
    # nixos-raspberrypi provides the RPi-specific image/boot logic instead.
    (modulesPath + "/installer/sd-card/sd-image-aarch64-installer.nix")
  ];

  services.openssh.enable = true;

  networking.hostName = "installer";
  networking.wireless.enable = lib.mkForce false;

  users.users.nixos.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILV1M/5M3gI/UpR1OR/zRAe3Eg03UYZDk2EptG78L14k nan0br3aker@gmail.com"
  ];

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILV1M/5M3gI/UpR1OR/zRAe3Eg03UYZDk2EptG78L14k nan0br3aker@gmail.com"
  ];

  image.baseName = lib.mkOverride 40 "nixos-${config.networking.hostName}";

  system.nixos.tags =
    let
      cfg = config.boot.loader.raspberry-pi;
    in
    [
      "raspberry-pi-${cfg.variant}"
      cfg.bootloader
      config.boot.kernelPackages.kernel.version
    ];
}
