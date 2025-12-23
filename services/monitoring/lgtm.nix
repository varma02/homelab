{ config, pkgs, ... }:

{
  systemd.services.init-monitoring-network = {
    description = "Create docker network for monitoring stack";
    after = [ "network.target" ];
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
        image = "grafana/grafana:latest";
        volumes = [
          "/persist/monitoring/grafana:/var/lib/grafana"
          "${./datasources.yaml}:/etc/grafana/provisioning/datasources/datasources.yaml:ro"
        ];
        networks = [ "monitoring" ];
        ports = [ "80:3000" ];
        dependsOn = [ "prometheus" "loki" "tempo" ];
      };
      # --- Alloy ---
      alloy = {
        image = "grafana/alloy:latest";
        user = "root";
        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock:ro"
          "${./config.alloy}:/etc/alloy/config.alloy:ro"
          "/proc:/host/proc:ro"
          "/sys:/host/sys:ro"
          "/:/host/root:ro"
        ];
        networks = [ "monitoring" ];
        cmd = [
          "run"
          "--server.http.listen-addr=0.0.0.0:12345"
          "--storage.path=/var/lib/alloy/data"
          "/etc/alloy/config.alloy"
        ];
      };
      # --- Prometheus ---
      prometheus = {
        image = "prom/prometheus:latest";
        volumes = [
          "${./prometheus.yaml}:/etc/prometheus/prometheus.yml:ro"
          "/persist/monitoring/prometheus:/prometheus"
        ];
        networks = [ "monitoring" ];
        cmd = [ 
          "--config.file=/etc/prometheus/prometheus.yml" 
          "--storage.tsdb.path=/prometheus" 
          "--web.console.libraries=/usr/share/prometheus/console_libraries"
          "--web.console.templates=/usr/share/prometheus/consoles"
          "--web.enable-remote-write-receiver"
        ];
      };
      # --- Loki ---
      loki = {
        image = "grafana/loki:latest";
        volumes = [
          "${./loki.yaml}:/etc/loki/local-config.yaml:ro"
          "/persist/monitoring/loki:/tmp/loki"
        ];
        networks = [ "monitoring" ];
        cmd = [ "-config.file=/etc/loki/local-config.yaml" ];
      };
      # --- Tempo ---
      tempo = {
        image = "grafana/tempo:latest";
        volumes = [
          "${./tempo.yaml}:/etc/tempo.yaml"
          "/persist/monitoring/tempo:/tmp/tempo"
        ];
        networks = [ "monitoring" ];
        cmd = [ "-config.file=/etc/tempo.yaml" ];
      };
    };
  };
}