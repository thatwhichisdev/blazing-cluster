{
  config,
  inputs,
  installerVariant,
  lib,
  modulesPath,
  pkgs,
  ...
}:
{
  imports = [
    inputs.nixos-images.nixosModules.sdimage-installer
    ../../modules/nix.nix
    ../../modules/openssh.nix
    ../../modules/time.nix
  ];

  disabledModules = [
    # Disable the standard nixos-images aarch64 installer module.
    # nixos-raspberrypi provides the RPi-specific image/boot logic instead.
    (modulesPath + "/installer/sd-card/sd-image-aarch64-installer.nix")
  ];

  environment.systemPackages = with pkgs; [
    ghostty.terminfo
    helix
  ];

  boot.zfs.forceImportRoot = false;

  networking.hostName = "installer-${installerVariant}";
  networking.wireless.enable = lib.mkForce false;

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
