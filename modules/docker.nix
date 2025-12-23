{
  systemd.services.init-monitoring-network = {
    description = "Docker persist permission fix";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = "chmod -R 777 /persist";
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
}