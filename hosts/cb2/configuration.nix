{ inputs, pkgs, config, lib, ... }: {
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
    ../../modules/chirpstack-concentratord/module.nix
    ../../modules/chirpstack-gateway-bridge/module.nix
    ../../modules/nix.nix
    ../../modules/security.nix
  ];

  networking.hostId = "32835dd8";
  networking.hostName = "computeblade2";

  users.users.nixos = {
    isNormalUser = true;
    name = "nixos";
    home = "/home/nixos";
    extraGroups = [ "wheel" "networkmanager" "input" "dialout" "plugdev" ];
    shell = pkgs.nushell;
  };

  home-manager.users.nixos.home = {
    enableNixpkgsReleaseCheck = false;
    homeDirectory = lib.mkForce "/home/nixos";
    stateVersion = "25.05";
  };

  services.chirpstack-concentratord = {
    enable = true;
    package = pkgs.chirpstack-concentratord;
    configFile = ../../modules/chirpstack-concentratord/concentratord.toml;
  };

  services.chirpstack-gateway-bridge = {
    enable = true;
    package = pkgs.chirpstack-gateway-bridge;
    configFile = ../../modules/chirpstack-gateway-bridge/gateway-bridge.toml;
  };

  system.nixos.tags = let cfg = config.boot.loader.raspberryPi;
  in [
    "raspberry-pi-${cfg.variant}"
    cfg.bootloader
    config.boot.kernelPackages.kernel.version
  ];

  system.stateVersion = config.system.nixos.release;
}
