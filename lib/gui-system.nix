{ pkgs, username, swww, customPackages, unstablePkgs, ... }:
{

  imports = [
    ../modules/dotfiles.nix
  ];

  # convenience for networking
  networking.networkmanager.enable = true;

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    wlr = {
      enable = true;
    };
    config = {
      common.default = ["gtk"];
      hyprland.default = ["gtk" "hyprland"];
    };
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd hyprland";
      };
    };
  };

  environment.sessionVariables = {
    XDG_DATA_DIRS = [
      "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}"
      "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
    ];
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  services.gnome.gnome-keyring.enable = true;

  services.flatpak.enable = true;

  programs.hyprland = {
    enable = true;
    package = unstablePkgs.hyprland;
  };

  programs.hyprlock = {
    enable = true;
    package = unstablePkgs.hyprlock;
  };

  # Peripheral stuff
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  environment.systemPackages = with pkgs; [
    # wayland tools
    wofi waybar swww.packages.${system}.swww customPackages.naga xdg-desktop-portal-gtk

    # Misc 
    gnome.gnome-settings-daemon gsettings-desktop-schemas

    alacritty

    # Applications
    customPackages.anytype
  ];

  fonts.packages = with pkgs; [
    (nerdfonts.override {
      fonts = [
        "FiraCode"
      ];
    })
  ];


  custom.dotfiles = {
    enable = true;
    user = username;
    files = {
      hyprland = {
        text = builtins.readFile ../dotfiles/hyprland.conf;
        target = ".config/hypr/hyprland.conf";
      };
      hyprlock = {
        text = builtins.readFile ../dotfiles/hyprlock.conf;
        target = ".config/hypr/hyprlock.conf";
      };
      alacritty = {
        text = builtins.readFile ../dotfiles/alacritty.toml;
        target = ".config/alacritty/alacritty.toml";
      };
      waybar1 = {
        text = builtins.readFile ../dotfiles/waybar/config.jsonc;
        target = ".config/waybar/config.jsonc";
      };
      waybar2 = {
        text = builtins.readFile ../dotfiles/waybar/modules.jsonc;
        target = ".config/waybar/modules.jsonc";
      };
      waybar3 = {
        text = builtins.readFile ../dotfiles/waybar/style.css;
        target = ".config/waybar/style.css";
      };

      xdefaults = {
        text = builtins.readFile ../dotfiles/Xdefaults;
        target = ".Xdefaults";
      };

    };
  };

}
