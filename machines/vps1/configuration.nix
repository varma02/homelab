
{ inputs, lib, pkgs, ... }:
{
  imports = [ 
    ../../modules/base.nix
    ../../modules/boot/grub.nix
    ./hardware.nix
  ];

  networking.hostName = "vps1";
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ ];
    allowedUDPPorts = [ ];
  };

}

