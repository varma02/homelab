{ pkgs, vars, config, inputs, ... }: {
  imports = [
    ./_packages.nix
  ];

  # --- USER ---
  users.mutableUsers = false;
  users.users.${vars.userName} = {
    isNormalUser = true;
    description = vars.userName;
    extraGroups = [ "wheel" "docker" ];
    openssh.authorizedKeys.keys = [
      vars.sshPublicKey
    ];
    shell = pkgs.zsh;
    password = "1234"; # TODO: REMOVE FOR PROD
  };
  console.keyMap = "hu";
  
  # --- SSH ---
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
    # openFirewall = true;
  };

  # --- FIREWALL ---
  networking.firewall.enable = true;

  # --- SYSTEM ---
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 15d";
    };
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      trusted-users = [ "${vars.userName}" ];
    };
  };
  system.stateVersion = "25.11";
}