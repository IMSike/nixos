{ config, lib, pkgs, modulesPath, ... }:

let
  unstable = import
    (builtins.fetchTarball https://github.com/nixos/nixpkgs/tarball/nixos-unstable)
    # reuse the current configuration
    { config = config.nixpkgs.config; };

  flake-compat = builtins.fetchTarball "https://github.com/edolstra/flake-compat/archive/master.tar.gz";
  hyprland = (import flake-compat {
    src = builtins.fetchTarball "https://github.com/hyprwm/Hyprland/archive/master.tar.gz";
  }).defaultNix;

in
{
  imports = [
    hyprland.homeManagerModules.default
  ];

  home.stateVersion = "23.05";

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
  };

  home.packages = with pkgs; [
    swww
    dmenu
    playerctl
    networkmanagerapplet
    baobab
    keepassxc
    gparted
    grim
    slurp
    wl-clipboard
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  programs.waybar = {
    enable = true;
    package = lib.mkDefault unstable.waybar;
    systemd = lib.mkDefault {
       enable = true;
       target = "basic.target";
    };
  };

  programs.fish = {
    enable = true;
  };

  programs.kitty = {
    enable = true;
    theme = lib.mkDefault "Nord";
    keybindings = lib.mkDefault {
      "ctrl+c" = "copy_or_interrupt";
      "ctrl+v" = "paste_from_clipboard";
      "ctrl+f>2" = "set_font_size 20";
    };
    settings = lib.mkDefault {
      enable_audio_bell = false;
      update_check_interval = 0;
    };
  };

  programs.starship = {
    enable = true;
  };

  programs.neovim = {
    enable = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.git = {
    enable = true;
  };

  programs.swaylock = {
    enable = true;
  };

  programs.btop = {
    enable = true;
    settings = lib.mkDefault {
      color_theme = "TTY";
      theme_background = false;
      truecolor = true;
    };
  };

  programs.wofi = {
    enable = true;
  };

  programs.rofi = {
    enable = true;
    terminal = lib.mkDefault "${pkgs.kitty}/bin/kitty";
    extraConfig = lib.mkDefault {
      modi = "drun,emoji,ssh,filebrowser,calc";
      case-sensitive = false;
      drun-categories = "";
      drun-match-fields = "name,generic,exec,categories,keywords";
      drun-display-format = "{name} [<span weight='light' size='small'><i>({generic})</i></span>]";
      drun-show-actions = false;
    };
    pass = {
      enable = true;
    };
  };

  programs.mpv = {
    enable = true;
    config = lib.mkDefault {
      profile = "gpu-hq";
      force-window = true;
      ytdl-format = "bestvideo+bestaudio";
      cache-default = 4000000;
    };
    scripts = with unstable.mpvScripts; lib.mkDefault [ mpris sponsorblock mpv-playlistmanager quality-menu thumbfast ];
  };

  programs.yt-dlp = {
    enable = true;
  };

  services.dunst = {
    enable = true;
  };

  services.swayidle = {
    enable = true;
    systemdTarget = "graphical-session.target";
    events = lib.mkDefault [
      { event = "before-sleep"; command = "${pkgs.swaylock}/bin/swaylock"; }
      { event = "lock"; command = "${pkgs.swaylock}/bin/swaylock -f"; }
    ];
    timeouts = lib.mkDefault [
      {
        timeout = 300;
        command = "${pkgs.swaylock}/bin/swaylock -f";
        resumeCommand = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
      }
      {
        timeout = 330;
        command = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off";
        resumeCommand = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
      }
      {
        timeout = 600;
        command = "${pkgs.systemd}/bin/systemctl suspend";
      }
    ];
  };

  services.playerctld = {
    enable = true;
  };

  services.mpd = {
    enable = true;
  };

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
  };

  xdg.userDirs.enable = true;

  gtk = {
    enable = true;
  };

  fonts.fontconfig.enable = true;

  xdg.mimeApps.enable = true;

}