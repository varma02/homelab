
{ inputs, pkgs, ... }:
{
  imports = [ 
    ../../modules/base.nix
    ./disko-config.nix
  ];

  networking.hostName = "vps1";
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 80 443 ];
    allowedUDPPorts = [ 443 ];
  };

}

