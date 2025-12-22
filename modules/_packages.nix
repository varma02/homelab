{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    efibootmgr
    git
    parted
    vim
  ];
  programs.zsh = {
    enable = true;
    ohMyZsh = {
      enable = true;
      theme = "amuse";
      plugins = [ "git" "docker" ];
    };
  };
}