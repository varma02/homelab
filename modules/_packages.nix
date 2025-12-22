{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    efibootmgr
    git
    parted
    vim
    zsh
    
  ];
}