{
  system.autoUpgrade = {
    enable = true;
    dates = "*-*-* 03:00:00";
    randomizedDelaySec = "30m";
    flake = "github:varma01/homelab:master";
  };
}