{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  sops = {
    defaultSopsFile = ../secrets.yaml;
    age = {
      keyFile = "/home/danko/.config/sops/age/keys.txt";
    };
    secrets = {
      danko_ssh_private_key = {
        path = ".ssh/id_ed25519";
      };
      danko_git_user_name = {};
      danko_git_user_email = {};
    };    
    # templates = {
    #   "danko_ssh_private_key_tpl".content = config.sops.placeholder.danko_ssh_private_key;
    # };
  };

  nixpkgs.config.allowUnfree = true;
  programs.home-manager.enable = true;

  home.username = "danko";
  home.homeDirectory = "/home/danko";
  home.stateVersion = "24.11";

  programs.fish = {
    enable = true;
    shellAliases = {
      nrs = "sudo nixos-rebuild switch --flake ~/nixos-conf/#nixos";
      hms = "home-manager switch --flake ~/nixos-conf/#danko";
    };
  };

  programs.git = {
    enable = true;
    userName = "@danko_git_user_name_placeholder@";
    userEmail = "@danko_git_user_email_placeholder@";
    extraConfig = {
      color = {
        ui = "auto";
        status = "auto";
        branch = "auto";
      };
      diff = {
        colorMoved = "zebra";
      };
      core = {
        editor = "hx";
      };
      init = {
        defaultBranch = "main";
      };
      pull = {
        rebase = true;
      };
      fetch = {
        prune = true;
      };
    };
  };

  home.activation.updateGitUserNameAndEmail = lib.hm.dag.entryAfter ["writeBoundary"] ''
    configFile=/home/danko/.config/git/config
    name_secret=$(cat "${config.sops.secrets.danko_git_user_name.path}")
    email_secret=$(cat "${config.sops.secrets.danko_git_user_email.path}")
    ${pkgs.gnused}/bin/sed -i "s#@danko_git_user_name_placeholder@#$name_secret#" "$configFile"
    ${pkgs.gnused}/bin/sed -i "s#@danko_git_user_email_placeholder@#$email_secret#" "$configFile"
  '';

  programs.firefox = {
    enable = true;
    profiles = {
      danko = {
        id = 0;
        name = "danko";
        isDefault = true;
        settings = {
          "accessibility.typeaheadfind.enablesound" = false;
          "browser.aboutConfig.showWarning" = false;
          "general.autoScroll" = true;
          "media.ffmpeg.vaapi.enabled" = true;
          "media.gmp-gmpopenh264.autoupdate" = true;
          "media.gmp-gmpopenh264.enabled" = true;
          "media.gmp-gmpopenh264.provider.enabled" = true;
          "media.peerconnection.video.h264_enabled" = true;
        };
      };
    };
    policies = (builtins.fromJSON (builtins.readFile ./files/firefox/policies.json)).policies;
  };

  home.packages = with pkgs; [
    age
    ansible
    atlas
    bat
    # beekeeper-studio
    bitwarden-cli
    bitwarden-desktop
    bleachbit
    bruno
    btop
    delta
    deno
    direnv
    discord
    docker
    dust
    gnome-extension-manager
    eza
    fastfetch
    fd
    # firefox
    # flatseal FLATPAK VERSION
    fzf
    # gearlever
    gh
    ghostty
    # git
    glow
    go
    # google-chrome
    handbrake
    helix
    kubernetes-helm
    hugo
    jq
    just
    k3d
    k9s
    kanata
    # kdePackages.kdeconnect-kde
    # gnomeExtensions.gsconnect
    kustomize
    kustomize-sops
    kubectl
    kubectx
    lazydocker
    lazygit
    logseq
    mkcert
    ncdu
    nettools   # net-tools
    nmap       # net-tools
    iftop      # net-tools
    tcpdump    # net-tools
    traceroute # net-tools
    whois      # net-tools
    nodejs_23
    onefetch
    pika-backup
    protobuf_27
    python3
    qbittorrent
    rclone
    restic
    ripgrep
    rsync
    rustup
    sd
    slack
    smartmontools
    smile
    sops
    stacer
    syncthing
    go-task
    thunderbird
    tlrc
    vlc
    vscode
    xh
    yq
    zed-editor
    zellij
    zoxide

    audacity
    # blender
    # davinci-resolve
    # gimp
    # inkscape
    # kdePackages.kdenlive
    # krita
    # obs-studio
  ];

  home.file = {
    Templates = {
      source = ./files/nautilus/Templates;
      recursive = true;
    };

    ".config/ghostty" = {
      source = ./files/ghostty;
      recursive = true;
    };

    ".config/helix" = {
      source = ./files/helix;
      recursive = true;
    };

    ".config/zed" = {
      source = ./files/zed;
      recursive = true;
    };

    ".ssh" = {
      source = ./files/ssh;
      recursive = true;
    };

    # ".ssh/id_ed25519" = {
    #   source = config.lib.file.mkOutOfStoreSymlink config.sops.templates."danko_ssh_private_key_tpl".path;
    # };
  };

  dconf.settings = {
    "org/gnome/desktop/input-sources" = {
      xkb-options = [ "caps:escape" ];
    };
  };
}
