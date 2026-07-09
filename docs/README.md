# Preview

![preview](preview.jpg)

# Overview

This repository shows how to configure and install NixOS on a cluster of Compute
Blade boards.

The repository includes:

- Guide on how to install and maintenance NixOS on your Compute Blade nodes.
- Custom installer images for compute module 4/5.
- Host configurations for individual Compute Blade nodes.

It is based on ![nixos-raspberrypi](https://github.com/nvmd/nixos-raspberrypi),
which provides NixOS support for Raspberry Pi Compute Modules.

# Getting Started

This guide explains how to boot a temporary NixOS installer image and then
install the final NixOS system onto the ComputeBlade SSD.

## Prerequisites

- Uptime Compute Blade DEV
- Raspberry Pi Compute Module 4/5
- NVMe SSD
- SD Card, only if your Compute Module doesn't have eMMC
- Network Switch POE+
- Linux machine with Nix

## Build the Installer Image

### Clone the repository

Clone the repository wherever you want to keep your cluster configuration files.
I usually keep mine under `~/.config.`.

```shell
git clone https://github.com/thatwhichisdev/blazing-cluster.git ~/.config/blazing-cluster
```

### Modify the installer configuration

For the best experience, add your public SSH key to the installer configuration.
This allows you to SSH into the installer without typing a password.

Modify following sections in `/hosts/installer/configuration.nix`

```nix
users.users.nixos.openssh.authorizedKeys.keys = [
  "<your public ssh key here>"
];

users.users.root.openssh.authorizedKeys.keys = [
  "<your public ssh key here>"
];
```

You can also add extra tools or temporary settings to the installer image if
needed.

Keep in mind that this installer system is not the final system. It is only used
to boot the board and run nixos-anywhere.

### Build the installer image

This repository defines separate installer images for Compute Module 4 and
Compute Module 5.

Run following command to generate installer, replace `<cmX>` with desired target
`cm4` or `cm5`.

```shell
nix --accept-flake-config build .#installerImages.installer-<cmX>
```

After the build finishes, the generated image will be available under
`result/sd-image/nixos-installer-<cmX>.img.zst`

## Flash the Installer Image

### Flash the image to SD card

Use this method only if your Compute Module does not have eMMC.

Connect the SD card to your Linux machine and find its device name using `lsblk`
command. It usually appears as something like `/dev/sdX`. No mounting needed.

Flash the image with following command:

```shell
sudo dd if=result/sd-image/nixos-installer-cm4.img.zst of=/dev/sdX bs=4M status=progress conv=fsync
```

Be careful: use the whole disk, for example `/dev/sdX`, not a partition like
`/dev/sdX1`.

### Flash the image onto eMMC

Use this method if your Compute Module has onboard eMMC.

This process requires putting the Compute Module into USB boot mode and flashing
the eMMC from your Linux machine.

This section will be documented later.

## Booting Installer Image

After flashing the installer image, insert the SD card into the ComputeBlade and
power on the board.

Once the board boots, find it on your local network. The hostname should be
`installer`.

You can SSH into the installer with:

```shell
ssh root@installer
```

Or by IP address, which you can locate in your router admin panel:

```shell
ssh root@<installer-ip-address>
```

If you added your SSH key to the installer configuration, key-based login should
work automatically, otherwise you need to connect external display via HDMI
cable and copy the password from the welcome message.

## Install NixOS

After the board has booted into the temporary installer image, install the final
NixOS system with nixos-anywhere.

The final system is installed to the SSD. Disk partitioning and ZFS setup are
handled by disko using the configuration from `/modules/disko.nix`.

To install system run:

```shell
nixos-anywhere --flake .#<system> root@<hostname>
```

Example:

```shell
nixos-anywhere --flake .#cb1 root@installer
```

Or, using an IP address:

```shell
nixos-anywhere --flake .#cb1 root@192.168.0.100
```

When the installation finishes, you should then be able to SSH into the final
NixOS host.

# Maintenance

This section will later describe how to manage the cluster and apply
configuration changes remotely.

# Licensing

The code in this project is licensed under MIT license. Check
[LICENSE](LICENSE.md) for further details.
