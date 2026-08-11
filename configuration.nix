{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen2
    ./hardware-configuration.nix
    ./snapper.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.zswap.enable = true;

  boot.plymouth = {
    enable = true;
    theme = "tribar";
  };

  networking.hostName = "vetiver";

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Berlin";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "de_DE.UTF-8";
      LC_MEASUREMENT = "de_DE.UTF-8";
      LC_MONETARY = "de_DE.UTF-8";
      LC_NAME = "de_DE.UTF-8";
      # LC_NUMERIC = "de_DE.UTF-8";
      LC_PAPER = "de_DE.UTF-8";
      LC_TELEPHONE = "de_DE.UTF-8";
      LC_TIME = "de_DE.UTF-8";
    };
  };

  fonts = {
    packages = with pkgs; [
      fantasque-sans-mono
    ];

    fontconfig = {
      antialias = true;
      hinting = {
        enable = true;
        style = "slight";
      };
      subpixel = {
        rgba = "rgb";
        lcdfilter = "default";
      };
    };
  };

  services.fprintd.enable = true;

  services.desktopManager.plasma6.enable = true;
  services.displayManager.plasma-login-manager.enable = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  services.power-profiles-daemon.enable = false;

  services.tlp = {
    enable = true;
    pd.enable = true;
    settings = {
      CPU_DRIVER_OPMODE_ON_AC = "active";
      CPU_DRIVER_OPMODE_ON_BAT = "active";
      CPU_DRIVER_OPMODE_ON_SAV = "active";
      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
      CPU_ENERGY_PERF_POLICY_ON_SAV = "power";
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 1;
      CPU_BOOST_ON_SAV = 0;
    };
  };

  users.users.aqrln = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "kvm"
    ];
    shell = pkgs.fish;
  };

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "aqrln" ];
  };

  programs.fish.enable = true;

  programs.firefox.enable = true;

  programs.nix-ld.enable = true;

  programs.gamemode.enable = true;
  programs.steam.enable = true;

  environment.systemPackages = with pkgs; [
    fd
    git
    helix
    htop
    jujutsu
    ripgrep
    wget
    wl-clipboard
    zellij
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  nixpkgs.config.allowUnfree = true;

  environment.sessionVariables = {
    EDITOR = "hx";
    VISUAL = "hx";
    NPM_CONFIG_PREFIX = "$HOME/.local";
  };

  environment.localBinInPath = true;

  system.stateVersion = "26.05";
}
