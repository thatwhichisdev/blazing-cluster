_: {
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;

  services.zfs.autoScrub.enable = true;
  services.zfs.trim.enable = true;

  disko.devices = {
    disk.nvme0 = {
      type = "disk";
      device = "/dev/nvme0n1";

      content = {
        type = "gpt";

        partitions = {
          FIRMWARE = {
            priority = 1;

            type = "0700";
            attributes = [
              0
            ];

            size = "1024M";

            label = "FIRMWARE";

            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot/firmware";
              mountOptions = [
                "noatime"
                "umask=0077"
              ];
            };
          };

          ESP = {
            type = "EF00";
            attributes = [
              2
            ];

            size = "1024M";

            label = "ESP";

            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [
                "noatime"
                "umask=0077"
              ];
            };
          };

          swap = {
            size = "8G";
            type = "8200";

            content = {
              type = "swap";
              discardPolicy = "both";
              priority = 10;

              resumeDevice = false;

              mountOptions = [ "nofail" ];
            };
          };

          zfs = {
            size = "100%";

            content = {
              type = "zfs";
              pool = "rpool";
            };
          };
        };
      };
    };

    zpool = {
      rpool = {
        type = "zpool";

        options = {
          ashift = "12";
          autotrim = "on";
        };

        rootFsOptions = {
          compression = "lz4";
          atime = "off";
          xattr = "sa";
          acltype = "posixacl";
          normalization = "formD";
          dnodesize = "auto";
          mountpoint = "none";
          canmount = "off";
        };

        postCreateHook =
          let
            poolName = "rpool";
          in
          ''
            zfs list -t snapshot -H -o name | grep -E '^${poolName}@blank$' || zfs snapshot ${poolName}@blank
          '';

        datasets = {
          local = {
            type = "zfs_fs";
            options.mountpoint = "none";
          };

          "local/nix" = {
            type = "zfs_fs";

            options = {
              reservation = "128M";
              mountpoint = "legacy";
            };

            mountpoint = "/nix";
          };

          system = {
            type = "zfs_fs";

            options = {
              mountpoint = "none";
            };
          };

          "system/root" = {
            type = "zfs_fs";

            options = {
              mountpoint = "legacy";
            };

            mountpoint = "/";
          };

          "system/var" = {
            type = "zfs_fs";

            options = {
              mountpoint = "legacy";
            };

            mountpoint = "/var";
          };

          safe = {
            type = "zfs_fs";

            options = {
              copies = "2";
              mountpoint = "none";
            };
          };

          "safe/home" = {
            type = "zfs_fs";

            options = {
              mountpoint = "legacy";
            };

            mountpoint = "/home";
          };

          "safe/var/lib" = {
            type = "zfs_fs";

            options = {
              mountpoint = "legacy";
            };

            mountpoint = "/var/lib";
          };
        };
      };
    };
  };
}
