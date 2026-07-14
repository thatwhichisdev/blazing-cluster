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

> [!NOTE]
> This guide expects that you are an experienced NixOS user, it doesn't cover
> how to create flake based configuration.

# Getting Started

This guide explains how to boot a temporary NixOS installer image and then
install the final NixOS system onto the Compute Blade's SSD.

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

For the best experience, add your public SSH key to the configuration. This
allows you to SSH into the installer and final system without typing a password.

Modify following sections in `/modules/openssh.nix`

```nix
users.users.nixos.openssh.authorizedKeys.keys = [
  "<your public ssh key here>"
];

users.users.root.openssh.authorizedKeys.keys = [
  "<your public ssh key here>"
];
```

You can also add extra tools or settings to the installer image if needed.

Keep in mind that this installer system is not the final system. It is only used
to boot the board and run nixos-anywhere.

### Build the installer image

This repository defines separate installer images for Compute Module 4 and
Compute Module 5.

Run following command to generate installer, replace `cmX` with desired
instalation target `cm4` or `cm5`.

```shell
nix --accept-flake-config build .#installerImages.installer-cmX
```

After the build finishes, the generated image will be available under
`result/sd-image/nixos-installer-cmX.img.zst`

## Flash the Installer Image

### Flash the image to SD card

Use this method only if your Compute Module does not have eMMC.

Connect the SD card to your Linux machine and find its device name using `lsblk`
command. It usually appears as something like `/dev/sdX`. No mounting needed.

Flash the image with following command, replace `cmX` and `sdX` with yours. with
yours:

```shell
zstdcat result/sd-image/nixos-installer-cmX.img.zst | sudo dd of=/dev/sdX bs=4M status=progress conv=fsync
```

> [!WARNING]
> Be careful: use the whole disk, for example `/dev/sdX`, not a partition like
> `/dev/sdX1`.

As confirmation that flashing completed successfully you will see metrics in the
console:

```shell
385+1 records in
385+1 records out
1618251606 bytes (1.6 GB, 1.5 GiB) copied, 49.1864 s, 32.9 MB/s
```

### Flash the image onto eMMC

Use this method if your Compute Module has onboard eMMC.

This process requires putting the Compute Module into USB boot mode and flashing
the eMMC from your Linux machine.

First, we need to install official raspberry's
![usbboot](https://github.com/raspberrypi/usbboot) tool to boot our compute
module over USB using `mass-storage-gadget` extension.

You can clone the official repository and build it following the official guide
or a more simple way would be to install it from `nixpkgs` via `nix-shell`, for
that just run following command:

```shell
nix-shell -p rpiboot
```

Now, run `rpiboot` as sudo to start listening for the compute module over USB:

```shell
sudo rpiboot
```

You will see following output

```shell
RPIBOOT: build-date 2026/05/09 pkg-version 20250908~162618~bookworm

Please fit the EMMC_DISABLE / nRPIBOOT jumper before connecting the power and USB cables to the target device.
If the device fails to connect then please see https://rpltd.co/rpiboot for debugging tips.

Waiting for BCM2835/6/7/2711/2712...
```

Move the USB switch on the Compute Blade to the USB Type-C position. Then, while
holding down the nRPIBOOT button on the blade connect the USB Type-C cable. You
will see following:

```shell
Directory not specified - trying default /nix/store/5knggxch09wj8qf7pgx6m19z3ib22b18-rpiboot-20250908-162618-bookworm/share/rpiboot/mass-storage-gadget64/
Sending bootcode.bin
Successful read 4 bytes
Waiting for BCM2835/6/7/2711/2712...

Second stage boot server
File read: mcb.bin
File read: memsys00.bin
File read: memsys01.bin
File read: memsys02.bin
File read: memsys03.bin
File read: memsys04.bin
File read: memsys05.bin
File read: memsys06.bin
File read: memsys07.bin
File read: memsys08.bin
File read: bootmain
Loading: /nix/store/5knggxch09wj8qf7pgx6m19z3ib22b18-rpiboot-20250908-162618-bookworm/share/rpiboot/mass-storage-gadget64//config.txt
File read: config.txt
Loading: /nix/store/5knggxch09wj8qf7pgx6m19z3ib22b18-rpiboot-20250908-162618-bookworm/share/rpiboot/mass-storage-gadget64//boot.img
File read: boot.img
Second stage boot server done
```

If everything finishes successfully, you should be able to see your eMMC via
`lsblk`:

```shell
[nix-shell:~/development/thatwhichisdev/blazing-cluster]$ lsblk
NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
sda           8:0    1   7.3G  0 disk
├─sda1        8:1    1     1G  0 part
└─sda2        8:2    1   6.3G  0 part
```

Flash the image with following command, replace `cmX` and `sdX` with yours. with
yours:

```shell
zstdcat result/sd-image/nixos-installer-cmX.img.zst | sudo dd of=/dev/sdX bs=4M status=progress conv=fsync
```

> [!WARNING]
> Be careful: use the whole disk, for example `/dev/sdX`, not a partition like
> `/dev/sdX1`.

As confirmation that flashing completed successfully you will see metrics in the
console:

```shell
385+1 records in
385+1 records out
1618251606 bytes (1.6 GB, 1.5 GiB) copied, 49.1864 s, 32.9 MB/s
```

## Booting Installer Image

After flashing the installer image, power on the board, if you're using SD card
don't forget to insert it.

Once the board boots, find it's IP address on your local network.

You can SSH into the installer with:

```shell
ssh root@<hostname>
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
nix run github:nix-community/nixos-anywhere -- --flake .#<system> root@<hostname>
```

Example:

```shell
nix run github:nix-community/nixos-anywhere -- --flake .#cb1 root@192.168.0.161
```

When the installation finishes, you should see following in the console:

```shell
kernel boot files installed for nixos generation '1-default'
removing obsolete generations in /boot/firmware/nixos...
generational bootloader installed
installation finished!
### Rebooting ###
Pseudo-terminal will not be allocated because stdin is not a terminal.
Warning: Permanently added '192.168.0.161' (ED25519) to the list of known hosts.
umount: /mnt/var/lib (rpool/safe/var/lib) unmounted
umount: /mnt/var (rpool/system/var) unmounted
umount: /mnt/nix (rpool/local/nix) unmounted
umount: /mnt/home (rpool/safe/home) unmounted
umount: /mnt/boot/firmware unmounted
umount: /mnt/boot unmounted
umount: /mnt (rpool/system/root) unmounted
### Waiting for the machine to become unreachable due to reboot ###
Warning: Permanently added '192.168.0.161' (ED25519) to the list of known hosts.
Warning: Permanently added '192.168.0.161' (ED25519) to the list of known hosts.
Warning: Permanently added '192.168.0.161' (ED25519) to the list of known hosts.
Warning: Permanently added '192.168.0.161' (ED25519) to the list of known hosts.
Warning: Permanently added '192.168.0.161' (ED25519) to the list of known hosts.
ssh: connect to host 192.168.0.161 port 22: Connection refused
### Done! ###
```

Now, connect via SSH and enjoy!

```shell
ssh nixos@<hostname>
```

# Maintenance

To change configuration of the running system you can simply run:

```shell
nixos-rebuild switch --flake .#<system> --target-host root@<hostname>
```

Otherwise you can clone this repository to the compute blade and run
`nixos-rebuild` directly on it, in my case I'm running Asahi Linux on M1 Mac, so
I have aarch64 on my main machine and building remotely usually is best choice
for me. If you have different architecture on your main machine builds might
take very long time to build, in that case you can indeed try to apply changes
within the blade itself.

## Update the bootloader EEPROM

If you wish to update the bootloader EEPROM of your compute module 4/5 boards
you can follow the steps below, unlike the booting Compute Module over USB in
`Flash the image onto eMMC` section, we actually want to reference to most
recent commits, so for that we'll have to clone the repository and build the
tool.

Clone the official ![usbboot](https://github.com/raspberrypi/usbboot)
repository.

```shell
git clone https://github.com/raspberrypi/usbboot ~/usbboot
```

Update the EEPROM submodule

```shell
git submodule update --init
```

Install the neccessary tools in order to build the binary

```shell
nix-shell -p pkg-config libusb1 gcc gnumake
```

Build the binary

```shell
make
```

Now you can update the EEPROM

For Compute Module 4:

```shell
sudo rpiboot -d recovery
```

For Compute Module 5:

```shell
sudo rpiboot -d recovery5
```

You will see following:

```shell
[nix-shell:~/development/raspberrypi/usbboot]$ sudo ./rpiboot -v -d recovery
RPIBOOT: build-date 2026/07/13 pkg-version local 87d6e032

Please fit the EMMC_DISABLE / nRPIBOOT jumper before connecting the power and USB cables to the target device.
If the device fails to connect then please see https://rpltd.co/rpiboot for debugging tips.

Boot directory 'recovery'
Loading: recovery/bootcode4.bin
Waiting for BCM2835/6/7/2711/2712...
```

Move the USB switch on the Compute Blade to the USB Type-C position. Then, while
holding down the nRPIBOOT button on the blade connect the USB Type-C cable. You
will see following:

```shell
Device located successfully
Loading: recovery/bootcode4.bin
Initialised device correctly
Found serial number 3
last_serial -1 serial 3
Sending bootcode.bin
libusb_bulk_transfer sent 24 bytes; returned 0
Writing 100140 bytes
libusb_bulk_transfer sent 100140 bytes; returned 0
Successful read 4 bytes
Waiting for BCM2835/6/7/2711/2712...

Device located successfully
Loading: recovery/bootcode4.bin
Initialised device correctly
Found serial number 4
last_serial -1 serial 4
Second stage boot server
Received message GetFileSize: config.txt
Loading: recovery/config.txt
File size = 254 bytes
Received message ReadFile: config.txt
File read: config.txt
libusb_bulk_transfer sent 254 bytes; returned 0
Received message GetFileSize: pieeprom.bin
libusb_bulk_transfer sent 0 bytes; returned 0
Cannot open file pieeprom.bin
Received message GetFileSize: pieeprom.upd
libusb_bulk_transfer sent 0 bytes; returned 0
Cannot open file pieeprom.upd
Received message GetFileSize: *USER_SERIAL_NUM*7b335499
{
        "USER_SERIAL_NUM": "7b335499"libusb_bulk_transfer sent 0 bytes; returned 0
Received message GetFileSize: *MAC_ADDR*2c:cf:67:22:08:f4
,
        "MAC_ADDR": "2c:cf:67:22:08:f4"libusb_bulk_transfer sent 0 bytes; returned 0
Received message GetFileSize: *CUSTOMER_KEY_HASH*0000000000000000000000000000000000000000000000000000000000000000
,
        "CUSTOMER_KEY_HASH": "0000000000000000000000000000000000000000000000000000000000000000"libusb_bulk_transfer sent 0 bytes; returned 0
Received message GetFileSize: *BOOT_ROM*000048b0
,
        "BOOT_ROM": "000048b0"libusb_bulk_transfer sent 0 bytes; returned 0
Received message GetFileSize: *BOARD_ATTR*40000000
,
        "BOARD_ATTR": "40000000"libusb_bulk_transfer sent 0 bytes; returned 0
Received message GetFileSize: *USER_BOARDREV*c03141
,
        "USER_BOARDREV": "c03141"libusb_bulk_transfer sent 0 bytes; returned 0
Received message GetFileSize: *JTAG_LOCKED*0
,
        "JTAG_LOCKED": "0"libusb_bulk_transfer sent 0 bytes; returned 0
Received message GetFileSize: *ADVANCED_BOOT*0000e8e8
,
        "ADVANCED_BOOT": "0000e8e8"libusb_bulk_transfer sent 0 bytes; returned 0
Received message Done: *ADVANCED_BOOT*0000e8e8
CMD exit

}
Second stage boot server done
```

Congratz, you successfully updated the bootloader EEPROM.

# Troubleshooting

If you experiecing issues, it always handy to explore system logs and try to
figure out what could be wrong, you can use following commands in such cases:

Diagnostic messages is the go-to tool for viewing low-level hardware detection,
driver initialization, and kernel error messages.

```shell
sudo dmesg -T -L
```

# Licensing

The code in this project is licensed under MIT license. Check
[LICENSE](LICENSE.md) for further details.
