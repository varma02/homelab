{ pkgs, ... }: 
{
  environment.systemPackages = with pkgs; [
    git
    parted
    vim
    curl
    dig
    net-tools
    btop
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