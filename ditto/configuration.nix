# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
    pkgsPersonal = import (builtins.fetchTarball {
    name = "nixpkgs-edvardsire";
    url = "https://github.com/EdvardSire/nixpkgs/archive/dc6b3d3775457d507e130aa6f2eba582d90b23ce.tar.gz";
    sha256 = "1r5bn10vd938c0vkah5q35rdh5zacl2hrz4dwdv6pypmz94xkjgf";
  }) { };
in
{
  nixpkgs.config.allowUnfree = true;
  imports = [ 
      ./hardware-configuration.nix
      ./cachix.nix
  ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  time.timeZone = "Europe/Oslo";
  i18n.defaultLocale = "en_US.UTF-8";

  networking = {
    hostName = "ditto";
    networkmanager.enable = true;
  };

  hardware = {
    opengl = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
      ];
    };
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    pulseaudio.enable = false;
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_6_11;
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  swapDevices = [{
	  device = "/var/lib/swapfile";
	  size = 2048;
  }];

  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    xkb = {
      layout = "us";
      variant = "";
    };
    excludePackages = [ pkgs.xterm ];
  };

  environment.sessionVariables.NIXOS_OZONE_WL = 1;
  environment.systemPackages = (with pkgs; [
    tree
    htop
    gitMinimal
    lazygit
    wget
    xsel
    nmap
    file
    jq
    zip
    unzip
    ncdu
    rsync
    ripgrep
    pdftk
    imagemagick_light
    config.boot.kernelPackages.perf
    vmtouch
    fzf
    lf
    zoxide
  ]) ++ (with pkgs; [
    terminator
    kdePackages.konsole
  ]) ++ (with pkgs; [
    pkgsPersonal.sioyek
    xournalpp
    thunderbird
    obsidian
    vlc
    eog
    geeqie
    feh
    gparted
    fido2-manage
    bruno
    libreoffice-qt6-still
    qgis-ltr
    element-desktop
    chromium
  ]) ++ (with pkgs; [
    (python312.withPackages (subpkgs: with subpkgs; [
      ipython
      numpy
      pyusb # https://github.com/alesya-h/zenbook-duo-2024-ux8406ma-linux
    ]))
    gcc13
    nodejs_20
  ]) ++ (with pkgs; [
    pyright
    llvmPackages_18.clang-tools
    vscode-langservers-extracted
    bash-language-server
  ]) ++ (with pkgs; [
    # https://github.com/alesya-h/zenbook-duo-2024-ux8406ma-linux
    inotify-tools
    gnome-monitor-config 
    usbutils
  ]) ++ (with pkgs; [
    # distrobox
    gnome-boxes
    freerdp3
  ]);

  # virtualisation.podman = {
  #   enable = true;
  #   dockerCompat = true;
  # };
  virtualisation.docker.enable = true;
  virtualisation.libvirtd.enable = true;
  users.extraGroups.docker.members = [ "user" ];

  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-gtk2;
  };
  programs.kdeconnect.enable = true;
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  programs.ladybird.enable = true;
  programs.chromium.enable = true;
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
    gnome-contacts
    gnome-weather
    gnome-maps
    gnome-music
    gnome-characters
    tali # poker game
    iagno # go game
    hitori # sudoku game
    atomix # puzzle game
    epiphany # web browser
    cheese # webcam tool
    geary # email reader
    evince # document viewer
    totem # video player
    yelp # gnome help
    simple-scan # document scanner
    file-roller
    gedit
  ]);

  users.users.user = {
    isNormalUser = true;
    home = "/home/user";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  security.sudo = {
    enable = true;
    extraRules = [{
      commands = [
        {
          command = "/usr/bin/env";
          options = [ "NOPASSWD" ];
        }
      ];
      groups = [ "wheel" ];
    }];
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
  ];


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
