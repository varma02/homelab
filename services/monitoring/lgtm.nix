{ config, pkgs, ... }:

{
  systemd.services.init-monitoring-network = {
    description = "Create docker network for monitoring stack";
    after = [ "docker.service" ];
    requires = [ "docker.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      ${pkgs.docker}/bin/docker network inspect monitoring >/dev/null 2>&1 || \
      ${pkgs.docker}/bin/docker network create monitoring
    '';
  };

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      # --- Grafana ---
      grafana = {
        image = "grafana/grafana:12.3";
        volumes = [
          "/persist/monitoring/grafana:/var/lib/grafana"
          "${./datasources.yaml}:/etc/grafana/provisioning/datasources/datasources.yaml:ro"
        ];
        networks = [ "monitoring" ];
        dependsOn = [ "prometheus" "loki" ];
        ports = [ "80:3000" ];
      };
      # --- Alloy ---
      alloy = {
        image = "grafana/alloy:v1.12.1";
        volumes = [
          "${./config.alloy}:/etc/alloy/config.alloy:ro"
          "/persist/monitoring/alloy:/var/lib/alloy/data"
          "/var/run/docker.sock:/var/run/docker.sock:ro"
          "/proc:/host/proc:ro"
          "/sys:/host/sys:ro"
          "/:/host/root:ro"
          "/var/log/journal:/var/log/journal:ro"
          "/etc/machine-id:/etc/machine-id:ro"
          "/var/lib/docker/:/var/lib/docker:ro"
          "/dev/disk/:/dev/disk:ro"
          "/run/udev:/run/udev:ro"
        ];
        networks = [ "monitoring" ];
        dependsOn = [ "prometheus" "loki" ];
        extraOptions = [
          "--privileged"
          "--user=root"
        ];
        cmd = [
          "run"
          "--server.http.listen-addr=0.0.0.0:4319"
          "--storage.path=/var/lib/alloy/data"
          "/etc/alloy/config.alloy"
        ];
      };
      # --- Prometheus ---
      prometheus = {
        image = "prom/prometheus:v3.8.1";
        volumes = [
          "${./prometheus.yaml}:/etc/prometheus/prometheus.yml:ro"
          "/persist/monitoring/prometheus:/prometheus"
        ];
        networks = [ "monitoring" ];
        cmd = [ 
          "--config.file=/etc/prometheus/prometheus.yml"
          "--storage.tsdb.path=/prometheus"
          "--web.enable-remote-write-receiver"
        ];
      };
      # --- Loki ---
      loki = {
        image = "grafana/loki:3.6";
        volumes = [
          "${./loki.yaml}:/etc/loki/local-config.yaml:ro"
          "/persist/monitoring/loki:/tmp/loki"
        ];
        networks = [ "monitoring" ];
        cmd = [ "-config.file=/etc/loki/local-config.yaml" ];
      };
    };
  };
}