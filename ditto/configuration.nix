# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;
  imports = [ 
      ./hardware-configuration.nix
  ];
  
  time.timeZone = "Europe/Oslo";
  i18n.defaultLocale = "en_US.UTF-8";

  networking.hostName = "ditto";
  networking.networkmanager.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  boot.kernelPackages = pkgs.linuxPackages_6_11;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;


  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.printing.enable = true;

  environment.sessionVariables.NIXOS_OZONE_WL = 1;
  environment.systemPackages = (with pkgs; [
    tree
    htop
    python312
    gitMinimal
    lazygit
    wget
    xsel
    nmap
    file
    jq
    zip
    unzip
    rsync
  ]) ++ (with pkgs; [
    terminator
    xournalpp
    thunderbird
    obsidian
    vlc
    eog
    gparted
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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
