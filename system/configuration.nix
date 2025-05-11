{ config, pkgs, inputs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    inputs.sops-nix.nixosModules.sops
  ];

  sops = {
    defaultSopsFile = ../secrets.yaml;
    age = {
      keyFile = "/home/danko/.config/sops/age/keys.txt";
    };
    secrets = {
      danko_password.neededForUsers = true;
    };
  };
  
  nixpkgs.config.allowUnfree = true;

  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 5d";
    };
  };

  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
    grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
      useOSProber = true;
      configurationLimit = 10;
      default = 2;
    };
    timeout = 2;
  };

  services.fstrim.enable = true;
  services.fstrim.interval = "weekly";

  zramSwap.enable = true;
  services.zram-generator.enable = true;

  networking = {
    hostName = "nixos";
    extraHosts = ''
      127.0.0.1 traefik.juicer-dev.xyz mail.juicer-dev.xyz juicer-dev.xy
      ::1 traefik.juicer-dev.xyz mail.juicer-dev.xyz juicer-dev.xy
    '';
    networkmanager.enable = true;
    wireless.enable = false;
    firewall.enable = false;
  };

  services.openssh.enable = true;

  time.timeZone = "Europe/Belgrade";
  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver.enable = false;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = true;
  services.xserver.desktopManager.gnome.enable = true;

  services.gnome.core-utilities.enable = true;
  services.gnome.games.enable = false;
  # services.gnome.core-shell.enable = false;
  # services.gnome.core-os-services.enable = false;

  environment.gnome.excludePackages = with pkgs; [
    # gnome-control-center # software center
    gnome-tour           # tour app
    yelp                 # help app
    epiphany             # browser
    geary                # email client
  ];

  services.xserver.excludePackages = with pkgs; [
    xterm # terminal
  ];

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.meslo-lg
    # corefonts
  ];
  fonts.fontconfig.enable = true;

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      nvidia-vaapi-driver
      libvdpau-va-gl
    ];
  };
  hardware.nvidia = {
    open = false;
    modesetting.enable = true;
  };
  
  nixpkgs.config.packageOverrides = pkgs: {
    intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
  };

  environment.variables = {
    LIBVA_DRIVER_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    WLR_NO_HARDWARE_CURSORS = "1";
    MOZ_DISABLE_RDD_SANDBOX = "1";
    NVD_BACKEND = "direct";
    EGL_PLATFORM = "wayland";
  };

  environment.sessionVariables = {
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
    XDG_DESKTOP_DIR = "$HOME/Desktop";
    XDG_DOWNLOAD_DIR = "$HOME/Downloads";
    EDITOR = "hx";
    ZDOTDIR = "$XDG_CONFIG_HOME/zsh";
    ANSIBLE_HOME = "$XDG_DATA_HOME/ansible";
    GOPATH = "$XDG_STATE_HOME/go";
    PYTHON_HISTORY = "$XDG_STATE_HOME/python";
    NPM_CONFIG_PREFIX = "$XDG_STATE_HOME/npm-global";
    PNPM_HOME = "$XDG_DATA_HOME/pnpm";
    RUSTUP_HOME = "$XDG_STATE_HOME/rustup";
    CARGO_HOME = "$XDG_STATE_HOME/cargo";
    PATH = "$PATH:$GOPATH/bin:$NPM_CONFIG_PREFIX/bin:$CARGO_HOME/bin";
  };

  services.frigate.vaapiDriver = "nvidia";
  services.fwupd.enable = true;
  services.flatpak.enable = true;
  services.printing.enable = false;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  services.libinput.enable = true;

  users.users.danko = {
    isNormalUser = true;
    description = "danko";
    extraGroups = [ "networkmanager" "wheel" "docker" "libvirtd" "kvm" ];
    shell = pkgs.zsh;
    hashedPasswordFile = config.sops.secrets.danko_password.path;
  };

  system.activationScripts.script.text = ''
    mkdir -p /var/lib/AccountsService/{icons,users}
    cp /home/danko/projects/nixos-conf/home/files/account-image/danko /var/lib/AccountsService/icons/danko
    echo -e "[User]\nIcon=/var/lib/AccountsService/icons/danko\n" > /var/lib/AccountsService/users/danko
    chown root:root /var/lib/AccountsService/users/danko
    chmod 0600 /var/lib/AccountsService/users/danko
    chown root:root /var/lib/AccountsService/icons/danko
    chmod 0444 /var/lib/AccountsService/icons/danko
  '';

  programs.fish.enable = true;
  programs.zsh.enable = true;
  # programs.firefox.enable = true;
  programs.dconf.enable = true;
  programs.appimage.enable = true;
  programs.appimage.binfmt = true;

  virtualisation = {
    docker = {
      enable = true;
      daemon.settings = builtins.fromJSON (builtins.readFile ../home/files/docker/daemon.json);
    };
    libvirtd.enable = true;
  };

  environment.systemPackages = with pkgs; [
    coreutils
    decibels # not yet in gnome core-utilities
    jdk
    gnome-boxes
    git
    curl
    wget
    tree
    nano
    zram-generator
    zip
    unzip
    gnutar
    gzip
    bzip2
    gnumake
    pwgen
    mkpasswd
    gnused
    gawk
    htop
    openssl
    wl-clipboard
    dconf-editor
    vulkan-loader
    vulkan-validation-layers
    vulkan-tools
    libva
    libva-utils
    ffmpeg-full
    ffmpegthumbnailer
    openh264
    x264
    x265
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-libav
    gst_all_1.gst-vaapi

    # gnomeExtensions.appindicator
    # libreoffice-fresh-unwrapped
    # hunspell
    # hunspellDicts,sr_RS
    # https://wiki.nixos/org/wiki/LibreOffice
  ];

  system.stateVersion = "24.11";
}
