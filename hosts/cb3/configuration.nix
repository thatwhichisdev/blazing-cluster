{
  inputs,
  pkgs,
  config,
  lib,
  ...
}:
{
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
    ../../modules/chirpstack-network-server/module.nix
    ../../modules/nix.nix
    ../../modules/security.nix
  ];

  networking.hostId = "20a48094";
  networking.hostName = "computeblade3";

  users.users.nixos = {
    isNormalUser = true;
    name = "nixos";
    home = "/home/nixos";
    extraGroups = [
      "wheel"
      "networkmanager"
      "input"
      "dialout"
      "plugdev"
    ];
    shell = pkgs.nushell;
  };

  home-manager.users.nixos.home = {
    enableNixpkgsReleaseCheck = false;
    homeDirectory = lib.mkForce "/home/nixos";
    stateVersion = "26.05";
  };

  # services.chirpstack-network-server = {
  #   enable = true;
  #   configFile = ../../modules/chirpstack-network-server/chirpstack.toml;
  #   regionFiles = [ ../../modules/chirpstack-network-server/region_eu868.toml ];
  #   openFirewall = true;
  #   uiPort = 8080;
  # };

  system.stateVersion = "26.05";
}
