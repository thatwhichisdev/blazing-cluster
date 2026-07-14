{
  description = "compute blade nixos flake based cluster configuration";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org/"
      "https://nixos-raspberrypi.cachix.org"
    ];

    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];

    experimental-features = [
      "flakes"
      "nix-command"
    ];

    trusted-users = [
      "root"
      "@build"
      "@wheel"
      "@admin"
    ];

    show-trace = true;
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    nixos-raspberrypi = {
      url = "github:nvmd/nixos-raspberrypi/nixos-26.05";
    };

    nixos-images = {
      url = "github:nvmd/nixos-images/sdimage-installer";
      inputs.nixos-stable.follows = "nixpkgs";
      inputs.nixos-unstable.follows = "nixpkgs";
    };

    nixos-anywhere = {
      url = "github:nix-community/nixos-anywhere";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixos-raspberrypi/nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixos-raspberrypi/nixpkgs";
    };

    blazing-fan = {
      url = "github:thatwhichisdev/blazing-fan/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixos-raspberrypi,
      disko,
      nixos-anywhere,
      ...
    }:
    let
      inherit (self) outputs;
    in
    {
      nixosConfigurations = {

        cb1 = nixos-raspberrypi.lib.nixosSystemFull {
          specialArgs = { inherit inputs outputs nixos-raspberrypi; };
          modules = [
            (
              {
                config,
                pkgs,
                lib,
                nixos-raspberrypi,
                disko,
                ...
              }:
              {
                imports = with nixos-raspberrypi.nixosModules; [
                  raspberry-pi-4.base
                  ./hosts/cb1/configuration.nix
                  ./hosts/cb1/hardware.nix
                ];
              }
            )
          ];
        };

        cb2 = nixos-raspberrypi.lib.nixosSystemFull {
          specialArgs = { inherit inputs outputs nixos-raspberrypi; };
          modules = [
            (
              {
                config,
                pkgs,
                lib,
                nixos-raspberrypi,
                disko,
                ...
              }:
              {
                imports = with nixos-raspberrypi.nixosModules; [
                  raspberry-pi-4.base
                  ./hosts/cb2/configuration.nix
                  ./hosts/cb2/hardware.nix
                ];
              }
            )
          ];
        };

        cb3 = nixos-raspberrypi.lib.nixosSystemFull {
          specialArgs = { inherit inputs outputs nixos-raspberrypi; };
          modules = [
            (
              {
                config,
                pkgs,
                lib,
                nixos-raspberrypi,
                disko,
                ...
              }:
              {
                imports = with nixos-raspberrypi.nixosModules; [
                  raspberry-pi-5.base
                  raspberry-pi-5.page-size-16k
                  ./hosts/cb3/configuration.nix
                  ./hosts/cb3/hardware.nix
                ];
              }
            )
          ];
        };

        cb4 = nixos-raspberrypi.lib.nixosSystemFull {
          specialArgs = { inherit inputs nixos-raspberrypi; };
          modules = [
            (
              {
                config,
                pkgs,
                lib,
                nixos-raspberrypi,
                disko,
                ...
              }:
              {
                imports = with nixos-raspberrypi.nixosModules; [
                  raspberry-pi-5.base
                  raspberry-pi-5.page-size-16k
                ];
              }
            )
            ./hosts/cb4/configuration.nix
            ./hosts/cb4/hardware.nix
          ];
        };

        installer-cm4 = nixos-raspberrypi.lib.nixosInstaller {
          specialArgs = {
            inherit inputs nixos-raspberrypi;
            installerVariant = "cm4";
          };
          modules = [
            (
              {
                nixos-raspberrypi,
                ...
              }:
              {
                imports = with nixos-raspberrypi.nixosModules; [
                  raspberry-pi-4.base
                  raspberry-pi-4.display-vc4
                  ./hosts/installer/configuration.nix
                  ./hosts/installer/hardware.nix
                ];
              }
            )
          ];
        };

        installer-cm5 = nixos-raspberrypi.lib.nixosInstaller {
          specialArgs = {
            inherit inputs nixos-raspberrypi;
            installerVariant = "cm5";
          };
          modules = [
            (
              {
                nixos-raspberrypi,
                ...
              }:
              {
                imports = with nixos-raspberrypi.nixosModules; [
                  raspberry-pi-5.base
                  raspberry-pi-5.display-vc4
                  raspberry-pi-5.page-size-16k
                  ./hosts/installer/configuration.nix
                  ./hosts/installer/hardware.nix
                ];
              }
            )
          ];
        };
      };

      installerImages =
        let
          nixos = self.nixosConfigurations;
          mkImage = nixosConfig: nixosConfig.config.system.build.sdImage;
        in
        {
          installer-cm4 = mkImage nixos.installer-cm4;
          installer-cm5 = mkImage nixos.installer-cm5;
        };

      formatter.aarch64-linux = nixpkgs.legacyPackages.aarch64-linux.nixfmt-tree;
    };
}
