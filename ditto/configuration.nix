# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  pkgsPersonal,
  winapps,
  nixpkgs-unstable,
  edvard-dotfiles,
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
        intel-compute-runtime # opencl
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
    extraModulePackages = with config.boot.kernelPackages; [ rtw88 ]; # usb wifi device
  };

  # Configure kernel options to make sure IOMMU & KVM support is on.
  # boot = {
  #   kernelModules = [
  #     "kvm-${platform}"
  #     "vfio_virqfd"
  #     "vfio_pci"
  #     "vfio_iommu_type1"
  #     "vfio"
  #   ];
  #   kernelParams = [
  #     "${platform}_iommu=on"
  #     "${platform}_iommu=pt"
  #     "kvm.ignore_msrs=1"
  #   ];
  #   extraModprobeConfig = "options vfio-pci ids=${builtins.concatStringsSep "," vfioIds}";
  # };

  systemd.tmpfiles.rules = [
    "f /dev/shm/looking-glass 0660 ${user} kvm -"
  ];

  virtualisation.docker.enable = true;
  users.extraGroups.docker.members = [ user ];

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
  ++ (import ./gui.nix { inherit pkgs;  })
  ++ (with pkgs; [
    # TERM
    terminator
    kdePackages.konsole
  ])
  ++ (with pkgs; [
    (python312.withPackages (
      subpkgs: with subpkgs; [
        ipython numpy matplotlib # for ipython3 --pylab
        pyusb # https://github.com/alesya-h/zenbook-duo-2024-ux8406ma-linux
      ]
    ))
    gcc13
    nodejs_20
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
  ])
  ++ (with pkgs; [
    edvard-dotfiles.packages.${system}.neovim
    edvard-dotfiles.packages.${system}.q-cli
    nixpkgs-unstable.legacyPackages.${system}.rerun
    nixpkgs-unstable.legacyPackages.${system}.sioyek
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

  programs.firefox = {
    enable = true;
    package = pkgs.librewolf;
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      Preferences = {
        # "bad" settings
        "webgl.disabled" = false;
        "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;

        "privacy.donottrackheader.enabled" = true;
        "cookiebanners.service.mode.privateBrowsing" = 2; # Block cookie banners in private browsing
        "cookiebanners.service.mode" = 2; # Block cookie banners
        "privacy.fingerprintingProtection" = true;
        "privacy.resistFingerprinting" = true;
        "privacy.trackingprotection.emailtracking.enabled" = true;
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.fingerprinting.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
      };
      ExtensionSettings = {
        "jid1-ZAdIEUB7XOzOJw@jetpack" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/duckduckgo-for-firefox/latest.xpi";
          installation_mode = "force_installed";
        };
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
        };
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
          installation_mode = "force_installed";
        };
        "addon@darkreader.org" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
          installation_mode = "force_installed";
        };
        "@testpilot-containers" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/multi-account-containers/latest.xpi";
          installation_mode = "force_installed";
        };
        "headereditor-amo@addon.firefoxcn.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/header-editor/latest.xpi";
          installation_mode = "force_installed";
        };
        "dfyoutube@example.com" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/df-youtube/latest.xpi";
          installation_mode = "force_installed";
        };
        "nb-NO@dictionaries.addons.mozilla.org" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/norsk-bokmål-ordliste/latest.xpi";
          installation_mode = "force_installed";
        };
      };
    };
  };

  environment.etc."firefox/policies/policies.json".target = "librewolf/policies/policies.json";

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







services.printing.enable = true;
services.avahi = {
  enable = true;
  nssmdns4 = true;
  openFirewall = true;
};


}
