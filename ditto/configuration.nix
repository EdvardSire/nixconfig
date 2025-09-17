# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  pkgsPersonal,
  winapps,
  ...
}:
let
  user = "user";
  platform = "intel";
  # Change this to specify the IOMMU ids you wrote down earlier.
  vfioIds = [
    "10de:1b80"
    "10de:10f0"
  ];
in
{
  nixpkgs.config.allowUnfree = true;

  imports = [ ./hardware-configuration.nix ];
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    substituters = [
      "https://attic.endurance-robotics.com/test-1"
    ];
    trusted-public-keys = [
      "test-1:01LhQktwt4ndXCqA7C/4lyTAMl3fkfrFtFqlWXYxGzQ="
    ];
    trusted-users = [ "user" ];
  };

  time.timeZone = "Europe/Oslo";
  i18n.defaultLocale = "en_US.UTF-8";

  networking = {
    hostName = "ditto";
    networkmanager.enable = true;
  };

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
      ];
    };

  };

  security.rtkit.enable = true;
  services = {
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    pulseaudio.enable = false;
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_6_12;
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    binfmt.emulatedSystems = [ "aarch64-linux" ];
  };

  # Configure kernel options to make sure IOMMU & KVM support is on.
  boot = {
    kernelModules = [
      "kvm-${platform}"
      "vfio_virqfd"
      "vfio_pci"
      "vfio_iommu_type1"
      "vfio"
    ];
    kernelParams = [
      "${platform}_iommu=on"
      "${platform}_iommu=pt"
      "kvm.ignore_msrs=1"
    ];
    extraModprobeConfig = "options vfio-pci ids=${builtins.concatStringsSep "," vfioIds}";
  };

  systemd.tmpfiles.rules = [
    "f /dev/shm/looking-glass 0660 ${user} kvm -"
  ];

  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  users.extraGroups.libvirtd.members = [ user ];

  hardware.nvidia.open = false; # For RTX 20xx cards
  services.xserver.videoDrivers = [ "nvidia" ];

  environment.sessionVariables.NIXOS_OZONE_WL = 1;
  environment.systemPackages = ([
    winapps.packages.${pkgs.system}.winapps
  ])
  ++ (import ./cli.nix { inherit pkgs config; })
  ++ (import ./gui.nix { inherit pkgs pkgsPersonal; })
  ++ (with pkgs; [
    # TERM
    terminator
    kdePackages.konsole
  ])
  ++ (with pkgs; [
    (python312.withPackages (
      subpkgs: with subpkgs; [
        ipython
        numpy
        pyusb # https://github.com/alesya-h/zenbook-duo-2024-ux8406ma-linux
      ]
    ))
    gcc13
    nodejs_20
  ])
  ++ (with pkgs; [
    pyright
    llvmPackages_18.clang-tools
    vscode-langservers-extracted
    bash-language-server
    typescript-language-server
    cmake-language-server
    nil
    nixfmt-rfc-style
    rust-analyzer
  ])
  ++ (with pkgs; [
    # https://github.com/alesya-h/zenbook-duo-2024-ux8406ma-linux
    inotify-tools
    gnome-monitor-config
    usbutils
  ])
  ++ (with pkgs; [
    # distrobox
    gnome-boxes
    freerdp3
  ]);

  users.users.user = {
    isNormalUser = true;
    home = "/home/user";
    extraGroups = [
      "networkmanager"
      "wheel"
      "dialout"
    ];
  };

  security.sudo = {
    enable = true;
    extraRules = [
      {
        commands = [
          {
            command = "/usr/bin/env";
            options = [ "NOPASSWD" ];
          }
        ];
        groups = [ "wheel" ];
      }
    ];
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 2048;
    }
  ];

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

  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-gtk2;
  };

  # programs.kdeconnect.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
    dumpcap.enable = true;
  };
  users.extraGroups.wireshark.members = [ "user" ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib
    ];
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
      DisplayMenuBar = "default-off"; # alternatives: "always", "never" or "default-on"
      SearchBar = "unified"; # alternative: "separate"
      OfferToSaveLogins = false;

      # ---- EXTENSIONS ----
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

  services.gnome.sushi.enable = true;
  environment.gnome.excludePackages = (
    with pkgs;
    [
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
    ]
  );

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
