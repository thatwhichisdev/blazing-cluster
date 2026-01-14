{ inputs, pkgs, config, lib, ... }:
let
  chirpstack-network-server =
    pkgs.callPackage ../../pkgs/chirpstack-network-server/package.nix { };
in {
  imports = [
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.home-manager
    ../../modules/boot.nix
    ../../modules/disko.nix
    ../../modules/git.nix
    ../../modules/helix.nix
    ../../modules/home-manager.nix
    ../../modules/networking.nix
    ../../modules/nushell.nix
    ../../modules/openssh.nix
    ../../modules/packages.nix
    ../../modules/time.nix
    ../../modules/udev.nix
    ../../modules/yazi.nix
    ../../modules/starship.nix
    ../../modules/fonts.nix
    ../../modules/redis.nix
    ../../modules/sqlite.nix
    ../../modules/mosquitto.nix
  ];

  environment.systemPackages = [ chirpstack-network-server ];

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" "pipe-operators" ];
    substituters = [ "https://nixos-raspberrypi.cachix.org" ];
    trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
    trusted-users = [ "root" "nixos" ];
  };

  users.users.nixos = {
    isNormalUser = true;
    name = "nixos";
    home = "/home/nixos";
    extraGroups =
      [ "wheel" "networkmanager" "video" "audio" "input" "dialout" "plugdev" ];
    shell = pkgs.nushell;
  };

  networking.hostId = "20a48094";
  networking.hostName = "computeblade3";

  security.polkit.enable = true;
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  system.nixos.tags = let cfg = config.boot.loader.raspberryPi;
  in [
    "raspberry-pi-${cfg.variant}"
    cfg.bootloader
    config.boot.kernelPackages.kernel.version
  ];

  home-manager.users.nixos.home = {
    enableNixpkgsReleaseCheck = false;
    homeDirectory = lib.mkForce "/home/nixos";
    stateVersion = "25.05";
  };

  # We are stateless, so just default to latest.inherit
  system.stateVersion = config.system.nixos.release;
}
