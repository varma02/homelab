{ lib, inputs, ... }:
{
  disko.devices = {
    disk.main = {
      device = lib.mkDefault "/dev/sda";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            name = "boot";
            size = "1M";
            type = "EF02";
          };
          ESP = {
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          root = {
            size = "100%";
            content = {
              type = "btrfs";
              subvolumes = {
                "@rootfs" = {
                  mountpoint = "/";
                };
                "@persist" = {
                  mountpoint = "/persist";
                };
                "@swap" = {
                  mountpoint = "/.swapvol";
                  swap = {
                    swapfile.size = "4G";
                  };
                };
              };
            };
            mountpoint = "/btrfs-root";
          };
        };
      };
    };
  };
}