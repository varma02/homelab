{ lib, inputs, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ "btrfs" ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  
  networking.useDHCP = false;
  networking.useNetworkd = true;
  services.cloud-init.enable = true;
  services.cloud-init.network.enable = true;
  services.cloud-init.settings = {
    datasource_list = [ "Hetzner" ];
  };

  disko.devices = {
    disk.main = {
      device = lib.mkDefault "/dev/sda";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            name = "boot";
            size = "5M";
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