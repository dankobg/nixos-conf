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

  #programs.fish = {
  #  enable = false;
  #  shellAliases = {
  #    nrs = "sudo nixos-rebuild switch --flake ~/nixos-conf/#nixos";
  #    hms = "home-manager switch --flake ~/nixos-conf/#danko";
  #  };
  #};

  #programs.zsh = {
  #  enable = true;
  #  shellAliases = {
  #    nrs = "sudo nixos-rebuild switch --flake ~/nixos-conf/#nixos";
  #    hms = "home-manager switch --flake ~/nixos-conf/#danko";
  #  };
  #};

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
    gopls # @TODO
    delve # @TODO
    gotools # @TODO
    gomodifytags # @TODO
    gotests # @TODO
    golangci-lint # @TODO
    golangci-lint-langserver # @TODO
    goreleaser # @TODO
    errcheck # @TODO
    impl # @TODO
    protobuf # @TODO
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
    nodejs_24
    pnpm
    nodePackages.prettier
    vscode-langservers-extracted # @TODO
    ansible-language-server # @TODO
    dockerfile-language-server-nodejs # @TODO
    docker-compose-language-service # @TODO
    typescript # @TODO
    typescript-language-server # @TODO
    svelte-language-server # @TODO
    # typescript-svelte-plugin # @TODO
    yaml-language-server # @TODO
    onefetch
    pika-backup
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
    zsh

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

    ".config/zsh" = {
      source = ./files/zsh;
      recursive = true;
    };
    ".config/zsh/plugins/powerlevel10k" = {
      source = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k";
      recursive = true;
    };
    ".config/zsh/plugins/zsh-autosuggestions" = {
      source = "${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions";
      recursive = true;
    };
    ".config/zsh/plugins/zsh-syntax-highlighting" = {
      source = "${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting";
      recursive = true;
    };
    ".config/zsh/plugins/zsh-completions" = {
      source = "${pkgs.zsh-completions}/share/zsh/site-functions";
      recursive = true;
    };
    ".config/zsh/plugins/fzf-tab" = {
      source = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
      recursive = true;
    };
  };

  dconf.settings = with lib.hm.gvariant; {
    "ca/desrt/dconf-editor" = {
      saved-pathbar-path = "/";
      saved-view = "/";
      show-warning = false;
    };
    "org/gnome/Console" = {
      audible-bell = false;
      custom-font = "JetBrainsMono Nerd Font 11";
      font-scale = 1.0;
      use-system-font = false;
    };
    "org/gnome/TextEditor" = {
      indent-style = "space";
      show-line-numbers = true;
      show-right-margin = false;
      tab-width = mkUint32 2;
      last-save-directory = "file:///home/danko/Downloads";
    };
    "org/gnome/Totem" = {
      active-plugins = [ "screenshot" "skipto" "vimeo" "autoload-subtitles" "apple-trailers" "rotation" "variable-rate" "screensaver" "mpris" "save-file" "recent" "movie-properties" "open-directory" ];
      subtitle-encoding = "UTF-8";
    };
    "org/gnome/baobab/ui" = {
      active-chart = "rings";
    };
    "org/gnome/boxes" = {
      first-run = false;
      view = "icon-view";
    };
    "org/gnome/calculator" = {
      accuracy = 9;
      angle-units = "degrees";
      base = 10;
      button-mode = "basic";
      number-format = "automatic";
      refresh-interval = 604800;
      show-thousands = false;
      show-zeroes = false;
      source-currency = "EUR";
      source-units = "degree";
      target-currency = "RSD";
      target-units = "radian";
      word-size = 64;
    };
    "org/gnome/calendar" = {
      active-view = "month";
    };
    "org/gnome/clocks/state/window" = {
      panel-id = "world";
    };
    "org/gnome/control-center" = {
      last-panel = "network";
    };
    "org/gnome/desktop/app-folders" = {
      folder-children = [ "Utilities" ];
    };
    "org/gnome/desktop/app-folders/folders/Utilities" = {
      apps = [ "org.freedesktop.GnomeAbrt.desktop" "nm-connection-editor.desktop" "org.gnome.baobab.desktop" "org.gnome.Connections.desktop" "org.gnome.DejaDup.desktop" "org.gnome.DiskUtility.desktop" "org.gnome.Evince.desktop" "org.gnome.FileRoller.desktop" "org.gnome.font-viewer.desktop" "org.gnome.Loupe.desktop" "org.gnome.seahorse.Application.desktop" "org.gnome.tweaks.desktop" "org.gnome.Usage.desktop" ];
      categories = [ "X-GNOME-Utilities" ];
      name = "X-GNOME-Utilities.directory";
      translate = true;
    };
    "org/gnome/desktop/background" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/blobs-l.svg";
      picture-uri-dark = "file:///run/current-system/sw/share/backgrounds/gnome/blobs-d.svg";
      primary-color = "#241f31";
      secondary-color = "#000000";
    };
    "org/gnome/desktop/calendar" = {
      show-weekdate = false;
    };
    "org/gnome/desktop/datetime" = {
      automatic-timezone = true;
    };
    "org/gnome/desktop/input-sources" = {
      mru-sources = [ (mkTuple [ "xkb" "us" ]) ];
      sources = [ (mkTuple [ "xkb" "us" ]) (mkTuple [ "xkb" "rs+latinyz" ]) (mkTuple [ "xkb" "rs" ]) ];
      xkb-options = [ "caps:escape" ];
    };
    "org/gnome/desktop/interface" = {
      accent-color = "purple";
      clock-show-date = true;
      clock-show-weekday = true;
      clock-show-seconds = false;
      color-scheme = "prefer-dark";
      gtk-enable-primary-paste = false;
    };
    "org/gnome/desktop/notifications" = {
      application-children = [ "org-gnome-console" "org-gnome-texteditor" "firefox" "gnome-power-panel" "code" "discord" ];
    };    
    "org/gnome/desktop/notifications/application/firefox" = {
      application-id = "firefox.desktop";
    };
    "org/gnome/desktop/notifications/application/gnome-power-panel" = {
      application-id = "gnome-power-panel.desktop";
    };
    "org/gnome/desktop/notifications/application/org-gnome-console" = {
      application-id = "org.gnome.Console.desktop";
    };
    "org/gnome/desktop/notifications/application/org-gnome-texteditor" = {
      application-id = "org.gnome.TextEditor.desktop";
    };
    "org/gnome/desktop/notifications/application/discord" = {
      application-id = "discord.desktop";
    };
    "org/gnome/desktop/notifications/application/code" = {
      application-id = "code.desktop";
    };
    "org/gnome/desktop/peripherals/keyboard" = {
      delay = mkUint32 265;
      numlock-state = false;
      repeat-interval = mkUint32 11;
    };
    "org/gnome/desktop/peripherals/mouse" = {
      accel-profile = "flat";
      speed = 0.5;
    };
    "org/gnome/desktop/peripherals/touchpad" = {
      two-finger-scrolling-enabled = true;
    };
    "org/gnome/desktop/privacy" = {
      old-files-age = mkUint32 30;
      recent-files-max-age = -1;
    };
    "org/gnome/desktop/screensaver" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/blobs-l.svg";
      primary-color = "#241f31";
      secondary-color = "#000000";
    };
    "org/gnome/desktop/search-providers" = {
      disabled = [];
      sort-order = [ "org.gnome.Settings.desktop" "org.gnome.Contacts.desktop" "org.gnome.Nautilus.desktop" ];
    };
    "org/gnome/desktop/session" = {
      idle-delay = mkUint32 900;
    };
    "org/gnome/evolution-data-server" = {
      migrated = true;
    };
    "org/gnome/gnome-system-monitor" = {
      current-tab = "resources";
      show-dependencies = false;
      show-whose-processes = "user";
    };
    "org/gnome/gnome-system-monitor/proctree" = {
      col-26-visible = false;
      col-26-width = 0;
    };
    "org/gnome/maps" = {
      last-viewed-location = [ 44.781272180712875 20.413749033296654 ];
      map-type = "MapsVectorSource";
      transportation-type = "pedestrian";
      window-maximized = true;
      zoom-level = 11;
    };
    "org/gnome/mutter" = {
      dynamic-workspaces = true;
      edge-tiling = true;
    };
    "org/gnome/nautilus/icon-view" = {
      default-zoom-level = "small";
    };
    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "icon-view";
      default-sort-order = "type";
      migrated-gtk-settings = true;
      search-filter-time-type = "last_modified";
      show-hidden-files = true;
    };
    "org/gnome/nautilus/compression" = {
      default-compression-format = "tar.xz";
    };
    "org/gnome/settings-daemon/plugins/color" = {
      night-light-enabled = true;
      night-light-schedule-automatic = false;
      night-light-temperature = mkUint32 2700;
    };
    "org/gnome/settings-daemon/plugins/media-keys" = {
      volume-step = 5;
      custom-keybindings = [ "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/" ];
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Super>period";
      command = "smile";
      name = "Smile emoji picker";
    };
    "org/gnome/settings-daemon/plugins/power" = {
      power-button-action = "interactive";
      sleep-inactive-ac-timeout = 2700;
      sleep-inactive-ac-type = "nothing";
    };    
    "org/gnome/shell" = {
      app-picker-layout = [];
      favorite-apps = [ "com.mitchellh.ghostty.desktop" "org.gnome.Nautilus.desktop" "firefox.desktop" "code.desktop" "dev.zed.Zed.desktop" "org.gnome.TextEditor.desktop" "Logseq.desktop" "bruno.desktop" "bitwarden.desktop" "discord.desktop" "slack.desktop" "thunderbird.desktop" ];
      welcome-dialog-last-shown-version = "48.0";
    };
    "org/gnome/shell/world-clocks" = {
      locations = [];
    };
    "org/gnome/software" = {
      check-timestamp = mkInt64 1746698711;
      first-run = false;
      flatpak-purge-timestamp = mkInt64 1746631857;
    };
    "org/gtk/gtk4/settings/file-chooser" = {
      date-format = "regular";
      location-mode = "path-bar";
      show-hidden = true;
      sidebar-width = 150;
      sort-column = "name";
      sort-directories-first = true;
      sort-order = "ascending";
      type-format = "category";
      view-type = "list";
    };
    "org/gtk/settings/file-chooser" = {
      date-format = "regular";
      location-mode = "path-bar";
      show-hidden = true;
      show-size-column = true;
      show-type-column = true;
      sidebar-width = 150;
      sort-column = "name";
      sort-directories-first = true;
      sort-order = "ascending";
      type-format = "category";
    };
  };  
}
    