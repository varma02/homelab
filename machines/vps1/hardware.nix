{ lib, inputs, ... }:
{
  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "virtio_pci" "virtio_scsi" "usbhid" "sr_mod" ];
    initrd.kernelModules = [ "btrfs" ];
    loader.grub.devices = [ "/dev/sda" ];
  };

  # # File systems
  # fileSystems."/" = {
  #   device = "/dev/disk/by-label/nixos";
  #   fsType = "btrfs";
  #   options = [ "subvol=@rootfs" "compress=zstd" "noatime" ];
  # };

  # fileSystems."/boot" = {
  #   device = "/dev/disk/by-label/ESP";
  #   fsType = "vfat";
  #   options = [ "fmask=0077" "dmask=0077" ];
  # };

  # fileSystems."/persist" = {
  #   device = "/dev/disk/by-label/nixos";
  #   fsType = "btrfs";
  #   options = [ "subvol=@persist" "compress=zstd" "noatime" ];
  # };

  # swapDevices = [ ];

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
          nixos = {
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
              };
            };
          };
        };
      };
    };
  };
}