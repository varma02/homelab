{ config, ... }:
{
  services.tailscale = {
    enable = true;
    openFirewall = true;
    authKeyFile = "/persist/tailscale/authkey";
    useRoutingFeatures = "server";
    extraUpFlags = [ "--accept-dns=false" "--advertise-exit-node" "--accept-routes" ];
    extraDaemonFlags = [ "--statedir=/persist/tailscale/state" ];
  };
}