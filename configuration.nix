# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;
  imports =
    [
      ./hardware-configuration.nix
      ./apple-silicon-support
      <home-manager/nixos>
    ];

  hardware.asahi.peripheralFirmwareDirectory = ./firmware;
  hardware.asahi.useExperimentalGPUDriver = true;
  hardware.asahi.setupAsahiSound = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  time.timeZone = "Europe/Oslo";
  networking.hostName = "nixos";
  networking.wireless.iwd = {
    enable = true;
    settings.General.EnableNetworkConfiguration = true;
  };

  environment.systemPackages = with pkgs; [
    tree
    htop
    terminator
    python312
    thunderbird
    gitMinimal
    lazygit
    sioyek
    wget
    xsel
  ];

  # home-manager.useGlobalPkgs = true;
  users.users.user = {
    isNormalUser = true;
    home = "/home/user";
    extraGroups = [ "wheel" ];
  };
  home-manager.useGlobalPkgs = true;
  home-manager.users.user = { pkgs, ... }: {
    dconf = {
      enable = true;
      settings = {
        "org/gnome/mutter" = {
          experimental-features = [ "scale-monitor-framebuffer" ];
        };
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
        };
      };
    };

    programs.neovim = {
      extraLuaConfig = ''
      :luafile ~/.config/nvim/init.lua
      '';
    };

    # xdg.configFile.nvim = {
    #   source = ./config;
    #   recursive = true;
    # };
    # home.file = lib.mapAttrs (name: type: {
    #   source = ./dotfiles/${name};
    #   recursive = type == "directory";
    # }) (builtins.readDir ./dotfiles);


    home.stateVersion = "24.11"; # Did you read the comment?
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  programs.firefox = {
    enable = true;
    languagePacks = [ "en-US" ];
     /* ---- POLICIES ---- */
     # Check about:policies#documentation for options.
    policies = {
     DisableTelemetry = true;
     DisableFirefoxStudies = true;
     EnableTrackingProtection = {
       Value= true;
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
     DisplayMenuBar = "default-off"; # alternatives: "always", "never" or "default-on"
     SearchBar = "unified"; # alternative: "separate"
     OfferToSaveLogins = false;

     /* ---- EXTENSIONS ---- */
     # Check about:support for extension/add-on ID strings.
     # Valid strings for installation_mode are "allowed", "blocked",
     # "force_installed" and "normal_installed".
     ExtensionSettings = {
       # "*".installation_mode = "blocked"; # blocks all addons except the ones specified below
       "uBlock0@raymondhill.net" = {
         install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
         installation_mode = "force_installed";
       };
       "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
         install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden/latest.xpi";
         installation_mode = "force_installed";
       };
     };
    };
  };
  

  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };
  services.xserver.xkb.layout = "us";
  services.xserver.videoDrivers = [ "displaylink" "modesetting" ]; # https://nixos.wiki/wiki/Displaylink

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



  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11"; # Did you read the comment?

}

