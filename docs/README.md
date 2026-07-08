# Preview

![preview_0](screenshot-0.png)

# Overview

Repository that guides you on how to configure your own cluster of compute
blades using nixos. Based on
![nixos-raspberrypi](https://github.com/nvmd/nixos-raspberrypi) which makes it
possible to install nixos on compute modules.

# Getting Started

## Prerequisites

- compute blade (dev version)
- ssd
- sd card (in case if you don't have an eMMC version of compute module)
- network switch with poe+ support
- (optional) more compute blades

## Installer Image Generation

### Clone repository

Clone the repository wherever you want to keep your cluster configuration files.
I usually keep mine under `~/.config.`.

```shell
git clone https://github.com/thatwhichisdev/blazing-cluster.git ~/.config/blazing-cluster
```

### Enrich the installer config with SSH keys

For the best experience I strongly recommend you to provide your public SSH keys
into the installer config so you can connect to the installer later on without
providing the password.

Modify following sections in `/hosts/installer/configuration.nix`

```nix
users.users.nixos.openssh.authorizedKeys.keys = [
  "<your public ssh key here>"
];

users.users.root.openssh.authorizedKeys.keys = [
  "<your public ssh key here>"
];
```

Additionally you can configure installer with additial tools or whatever you
want, but we'll re-install the system anyway using `nixos-anywhere` so installer
nixos image is temporary thing.

### Build the installer SD image

This repo defines two installers for both compute module 4 and 5, you can also
reference [nixos-repository](https://github.com/nvmd/nixos-raspberrypi) to see
how to build you image or use the pre-built one.

Run following command to generate installer for compute module 5

```shell
nix --accept-flake-config build .#installerImages.installer-cm5
```

and for compute module 4

```shell
nix --accept-flake-config build .#installerImages.installer-cm4
```

As command finished, you will find generated images within project folder,
follow the path `result/sd-image/nixos-installer-cm*.img.zst`.

## Installer Image Flashing

### Flash the image onto SD card

I'm using linux and hence `dd` utility helps me write image to the sd card,
connect your sd card and locate it using `lsblk` command, usually they are
displayed as `sdX` where `X` is a random letter, no need to mount.

Then use the command template from below to write generated image to the sd
card.

```shell
sudo dd if=result/sd-image/nixos-installer-cm4.img.zst of=/dev/sdX bs=4M status=progress conv=fsync
```

### Flash the image onto eMMC

Will describe this process later, since it's more complicated and requires
additional tools.

## Booting Installer Image

Now as you have you SD card with installer image ready to go you can insert it
into the compute blade and boot the board.

You should be able to locate the blade on you local network, the hostname will
be `installer`.

## Installing NixOS

So now when we finally have our board booted with the installer image we can
install the actual NixOS configuration, unfortunatly there is no way currently
to install NixOS directly on the SSD or do it over the network, so we always
have to install NixOS using temporary installer image.

Run following command to install NixOS using `nixos-anywhere`, you should supply
you system configuration and hostname. Disko will set up SSD using the ZFS
configuration provided in `/modules/disko.nix`.

```shell
nixos-anywhere --flake .#<system> root@<hostname>"
```

As soon as the process is done you should be able to SSH into the system.

# Maintenance

Will describe later how to manage your system and apply changes remotely.

# Licensing

The code in this project is licensed under MIT license. Check
[LICENSE](LICENSE.md) for further details.
