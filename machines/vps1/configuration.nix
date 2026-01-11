
{ inputs, lib, pkgs, ... }:
{
  imports = [ 
    ./hardware.nix
    ../../modules/boot/grub.nix
    ../../modules/base.nix
    ../../modules/docker.nix
    ../../services/netdata.nix
  ];

  networking.hostName = "vps1";
  # networking.firewall.allowedTCPPorts = [ 80 443 ];
  # networking.firewall.allowedUDPPorts = [ 443 ];
}

