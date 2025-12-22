{ pkgs, ... }: 
{
  environment.systemPackages = with pkgs; [
    git
    parted
    vim
    curl
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