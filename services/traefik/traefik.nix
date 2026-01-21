{ pkgs, ... }:
{
  # networking.firewall.allowedTCPPorts = [ 80 443 ];
  # networking.firewall.allowedUDPPorts = [ 443 ];

  systemd.services.init-traefik-network = {
    description = "Create docker network for traefik";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      (${pkgs.docker}/bin/docker network remove traefik >/dev/null 2>&1 &&
      ${pkgs.docker}/bin/docker network create --internal traefik) || true
    '';
  };

  virtualisation.oci-containers.containers.traefik = {
    image = "traefik:v3.6";
    ports = [ "80:80" "443:443" ];
    volumes = [
      "${./main.yaml}:/etc/traefik/traefik.yaml:ro"
      "${./dynamic}:/app/dynamic:ro"
      "/var/run/docker.sock:/app/docker.sock:ro"
      "/persist/traefik/data/acme:/app/acme"
      "/persist/traefik/logs:/app/logs"
    ];
    networks = [ "traefik" "internet" ];
    environmentFiles = [ "/persist/traefik/cloudflare-dns-api-key" ];
    labels = {
      "traefik.enable" = "true";
      "traefik.http.routers.traefik.rule" = "Host(`traefik.vps1.ts.varma01.dev`)";
      "traefik.http.routers.traefik.entrypoints" = "websecure";
      "traefik.http.routers.traefik.tls.certresolver" = "cf";
      "traefik.http.routers.traefik.service" = "api@internal";
      "traefik.http.routers.traefik.middlewares" = "tailnet-only@file";
    };
  };
}