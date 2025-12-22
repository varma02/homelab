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
  
  # --- SSH ---
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
    openFirewall = true;
  };

  # --- FIREWALL ---
  networking.firewall = {
    enable = false;
    allowedTCPPorts = [ ];
    allowedUDPPorts = [ ];
  };

  # --- SYSTEM ---
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 10d";
    };
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
  };
  system.stateVersion = "25.11";
}