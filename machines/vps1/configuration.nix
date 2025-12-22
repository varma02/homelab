
{ inputs, lib, pkgs, ... }:
{
  imports = [ 
    ../../modules/base.nix
    ../../modules/boot/grub.nix
    ./disko.nix
  ];

  networking.hostName = "vps1";
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 80 443 ];
    allowedUDPPorts = [ 443 ];
  };

}

