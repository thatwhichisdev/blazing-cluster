{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.home-manager
    inputs.agenix.nixosModules.default
    ../../modules/blazing-fan.nix
    ../../modules/boot.nix
    ../../modules/disko.nix
    ../../modules/fonts.nix
    ../../modules/ghostty.nix
    ../../modules/git.nix
    ../../modules/helix.nix
    ../../modules/home-manager.nix
    ../../modules/networking.nix
    ../../modules/nix.nix
    ../../modules/nushell.nix
    ../../modules/openssh.nix
    ../../modules/opentelemetry.nix
    ../../modules/packages.nix
    ../../modules/security.nix
    ../../modules/starship.nix
    ../../modules/time.nix
    ../../modules/udev.nix
    ../../modules/yazi.nix
  ];

  networking.hostId = "d3c2bfdf";
  networking.hostName = "computeblade1";

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

  users.users.root = {
    shell = pkgs.nushell;
  };

  home-manager.users.nixos.home = {
    homeDirectory = lib.mkForce "/home/nixos";
    stateVersion = "26.05";
  };

  home-manager.users.root.home = {
    homeDirectory = lib.mkForce "/root";
    stateVersion = "26.05";
  };

  system.stateVersion = config.system.nixos.release;
}
