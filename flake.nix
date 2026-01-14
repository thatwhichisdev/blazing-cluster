{
  description = "Blazing Cluster";

  nixConfig = {
    bash-prompt = "[compute blade] ➜ ";
    extra-substituters = [ "https://nixos-raspberrypi.cachix.org" ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
    experimental-features = [ "flakes" "nix-command" ];
    connect-timeout = 5;
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-raspberrypi = { url = "github:nvmd/nixos-raspberrypi/main"; };
    nixos-anywhere = { url = "github:nix-community/nixos-anywhere"; };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixos-raspberrypi/nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixos-raspberrypi/nixpkgs";
    };
  };

  outputs =
    inputs@{ self, nixpkgs, nixos-raspberrypi, disko, nixos-anywhere, ... }:
    let inherit (self) outputs;
    in {
      nixosConfigurations = {

        cb1 = nixos-raspberrypi.lib.nixosSystem {
          specialArgs = { inherit inputs outputs nixos-raspberrypi; };
          modules = [
            ({ config, pkgs, lib, nixos-raspberrypi, disko, ... }: {
              imports = with nixos-raspberrypi.nixosModules; [
                raspberry-pi-4.base
                ./hosts/cb1/configuration.nix
                ./hosts/cb1/hardware.nix
              ];
            })
          ];
        };

        cb2 = nixos-raspberrypi.lib.nixosSystem {
          specialArgs = { inherit inputs outputs nixos-raspberrypi; };
          modules = [
            ({ config, pkgs, lib, nixos-raspberrypi, disko, ... }: {
              imports = with nixos-raspberrypi.nixosModules; [
                raspberry-pi-4.base
                ./hosts/cb2/configuration.nix
                ./hosts/cb2/hardware.nix
              ];
            })
          ];
        };

        cb3 = nixos-raspberrypi.lib.nixosSystemFull {
          specialArgs = { inherit inputs outputs nixos-raspberrypi; };
          modules = [
            ({ config, pkgs, lib, nixos-raspberrypi, disko, ... }: {
              imports = with nixos-raspberrypi.nixosModules; [
                raspberry-pi-5.base
                raspberry-pi-5.page-size-16k
                ./hosts/cb3/configuration.nix
                ./hosts/cb3/hardware.nix
              ];
            })
            ({ config, pkgs, lib, ... }:
              let kernelBundle = pkgs.linuxAndFirmware.v6_6_31;
              in {
                boot = {
                  loader.raspberryPi.firmwarePackage =
                    kernelBundle.raspberrypifw;
                  loader.raspberryPi.bootloader = "kernel";
                  kernelPackages = kernelBundle.linuxPackages_rpi5;
                };

                nixpkgs.overlays = lib.mkAfter [
                  (self: super: {
                    inherit (kernelBundle) raspberrypiWirelessFirmware;
                    inherit (kernelBundle) raspberrypifw;
                  })
                ];
              })

          ];
        };

        cb4 = nixos-raspberrypi.lib.nixosSystemFull {
          specialArgs = { inherit inputs nixos-raspberrypi; };
          modules = [
            ({ config, pkgs, lib, nixos-raspberrypi, disko, ... }: {
              imports = with nixos-raspberrypi.nixosModules; [
                raspberry-pi-5.base
                raspberry-pi-5.page-size-16k
                ./hosts/cb4/configuration.nix
                ./hosts/cb4/hardware.nix
              ];
            })
            ({ config, pkgs, lib, ... }:
              let kernelBundle = pkgs.linuxAndFirmware.v6_6_31;
              in {
                boot = {
                  loader.raspberryPi.firmwarePackage =
                    kernelBundle.raspberrypifw;
                  loader.raspberryPi.bootloader = "kernel";
                  kernelPackages = kernelBundle.linuxPackages_rpi5;
                };

                nixpkgs.overlays = lib.mkAfter [
                  (self: super: {
                    inherit (kernelBundle) raspberrypiWirelessFirmware;
                    inherit (kernelBundle) raspberrypifw;
                  })
                ];
              })

          ];
        };

      };

    };
}
