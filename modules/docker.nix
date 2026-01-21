{ pkgs, ... }:
{
  # systemd.services.docker-permissions-fix = {
  #   description = "Docker persist permission fix";
  #   after = [ "network.target" ];
  #   wantedBy = [ "multi-user.target" ];
  #   serviceConfig.Type = "oneshot";
  #   script = "chmod -R 777 /persist";
  # };

  systemd.services.init-internet-network = {
    description = "Create docker network for internet access";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      (${pkgs.docker}/bin/docker network remove internet >/dev/null 2>&1 &&
      ${pkgs.docker}/bin/docker network create --driver bridge --opt com.docker.network.bridge.enable_icc=false internet) || true
    '';
  };

  virtualisation.docker = {
    enable = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
    daemon.settings = {
      ipv6 = true;
    };
  };

  virtualisation.oci-containers.backend = "docker";
}