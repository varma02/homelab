
{ config, lib, pkgs, ... }:
{

  virtualisation.docker.enable = true;

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      traefik = {
        image = "traefik:3.6";
        autoStart = true;
        extraOptions = [ "--network=host" ];
        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock:ro"
          "/syscfg/services/traefik/traefik.yaml:/etc/traefik/traefik.yaml:ro"
          "/syscfg/services/traefik/dynamic:/etc/traefik/dynamic:ro"
          "/persistent/traefik:/appdata"
        ];
      };
    };
  };

}
