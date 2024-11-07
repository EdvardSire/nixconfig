# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;
  imports = [
    ./hardware-configuration.nix
    ./apple-silicon-support
    <home-manager/nixos>
  ];

  time.timeZone = "Europe/Oslo";
  networking.hostName = "nixos";
  networking.wireless.iwd = {
    enable = true;
    settings.General.EnableNetworkConfiguration = true;
  };

  hardware.asahi.peripheralFirmwareDirectory = ./firmware;
  hardware.asahi.useExperimentalGPUDriver = true;
  hardware.asahi.setupAsahiSound = true;
  hardware.spacenavd.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  swapDevices = [ {
    device = "/var/lib/swapfile";
    size = 2048;
  } ];

  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;

  };
  services.xserver.xkb.layout = "us";
  services.xserver.videoDrivers =
    [ "displaylink" "modesetting" ]; # https://nixos.wiki/wiki/Displaylink

  virtualisation.docker.enable = true;
  users.extraGroups.docker.members = [ "user" ];

  networking.wg-quick.interfaces.wg0.configFile =
    "/etc/nixos/files/wireguard/wg0.conf";

  environment.sessionVariables.NIXOS_OZONE_WL = 1;
  environment.systemPackages = (with pkgs; [
    tree
    htop
    python312
    gitMinimal
    lazygit
    wget
    xsel
    wireguard-tools
    ripgrep
    nmap
    ruff
    file
    vlc
    jq
    eyedropper
    typer
    zip
    unzip
    rsync
    calculix
    gmsh
    spacenavd
    nodejs_18
  ]) ++ (with pkgs; [
    terminator
    sioyek
    thunderbird
    libreoffice-qt6-fresh
    obsidian
    gparted
    qgroundcontrol
    freecad
    qgis
    eog
  ]) ++ (with pkgs; [
    ruff-lsp
    clang-tools
    pyright
  ]) ++ (with pkgs; [
    gnome-calculator
    gnomeExtensions.vitals
  ]);

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  programs.firefox = {
    enable = true;
    languagePacks = [ "en-US" ];
    # ---- POLICIES ----
    # Check about:policies#documentation for options.
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
      DisablePocket = true;
      DisableFirefoxAccounts = true;
      DisableAccounts = true;
      DisableFirefoxScreenshots = true;
      OverrideFirstRunPage = "";
      OverridePostUpdatePage = "";
      DontCheckDefaultBrowser = true;
      DisplayBookmarksToolbar = "never"; # alternatives: "always" or "newtab"
      DisplayMenuBar =
        "default-off"; # alternatives: "always", "never" or "default-on"
      SearchBar = "unified"; # alternative: "separate"
      OfferToSaveLogins = false;

      # ---- EXTENSIONS ----
      # Check about:support for extension/add-on ID strings.
      # Valid strings for installation_mode are "allowed", "blocked",
      # "force_installed" and "normal_installed".
      ExtensionSettings = {
        # "*".installation_mode = "blocked"; # blocks all addons except the ones specified below
        "uBlock0@raymondhill.net" = {
          install_url =
            "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
        };
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
          install_url =
            "https://addons.mozilla.org/firefox/downloads/latest/bitwarden/latest.xpi";
          installation_mode = "force_installed";
        };
      };
    };
  };

  services.gnome.sushi.enable = true;
  environment.gnome.excludePackages = (with pkgs; [
    gnome-photos
    gnome-tour
    gnome-connections
    gnome-console
    gnome-calculator
    gnome-calendar
    gnome-system-monitor
    gnome-terminal
    gedit
    epiphany # web browser
    cheese # webcam tool
    geary # email reader
    evince # document viewer
    totem # video player
    yelp # gnome help
    simple-scan # document scanner
    file-roller
  ]) ++ (with pkgs.gnome; [
    gnome-contacts
    gnome-weather
    gnome-maps
    gnome-music
    gnome-characters
    tali # poker game
    iagno # go game
    hitori # sudoku game
    atomix # puzzle game
  ]); 

  users.users.user = {
    isNormalUser = true;
    home = "/home/user";
    extraGroups = [ "wheel" "dialout" ];
  };
  home-manager.useGlobalPkgs = true;
  home-manager.users.user = { pkgs, config, ... }: {

    dconf = {
      enable = true;
      settings = {
        "org/gnome/mutter" = {
          experimental-features = [ "scale-monitor-framebuffer" ];
        };
        "org/gnome/desktop/interface" = { color-scheme = "prefer-dark"; };
        "org/gnome/desktop/remote-desktop/rdp" = {
          screen-share-mode = "extend";
        };
        "org/gnome/shell" = {
        };
      };
    };

    home.sessionVariables.NIXOS_OZONE_WL = "1";

    home.file.".gitconfig".source =
      config.lib.file.mkOutOfStoreSymlink "/home/user/dotfiles/.gitconfig";
    home.file.".config/nvim".source =
      config.lib.file.mkOutOfStoreSymlink "/home/user/dotfiles/nvim";
    home.file.".bashrc".source =
      config.lib.file.mkOutOfStoreSymlink "/home/user/dotfiles/bash/bashrc";

    home.stateVersion = "24.11"; # Did you read the comment?
  };


  ### 
  system.stateVersion = "24.11"; # Did you read the comment?

}

