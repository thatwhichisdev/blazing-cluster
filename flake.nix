{
  description = "NixOS cluster configuration for Compute Blades";

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
      "thatwhichisapple"
      "root"
      "@build"
      "@wheel"
      "@admin"
    ];

    show-trace = true;
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/nixos-26.05";

    nixos-images.url = "github:nvmd/nixos-images/sdimage-installer";
    nixos-images.inputs.nixos-stable.follows = "nixpkgs";
    nixos-images.inputs.nixos-unstable.follows = "nixpkgs";

    nixos-anywhere.url = "github:nix-community/nixos-anywhere";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixos-raspberrypi/nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixos-raspberrypi/nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    blazing-fan.url = "github:thatwhichisdev/blazing-fan/master";
    blazing-fan.inputs.nixpkgs.follows = "nixpkgs";
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

      supportedSystems = [
        "aarch64-linux"
        "x86_64-linux"
      ];

      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      nixosConfigurations = {

        cb1 = nixos-raspberrypi.lib.nixosSystemFull {
          specialArgs = { inherit inputs outputs nixos-raspberrypi; };
          modules = [
            (
              {
                nixos-raspberrypi,
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
                nixos-raspberrypi,
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
                nixos-raspberrypi,
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
                nixos-raspberrypi,
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

      packages = forAllSystems (_system: {
        installer-cm4 = self.nixosConfigurations.installer-cm4.config.system.build.sdImage;
        installer-cm5 = self.nixosConfigurations.installer-cm5.config.system.build.sdImage;
      });

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);
    };
}
