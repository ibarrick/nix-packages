{ pkgs, username, swww, naga, unstablePkgs, customModules, ... }:
{

  imports = [
    customModules
  ];

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

  programs.hyprland = {
    enable = true;
    package = unstablePkgs.hyprland;
  };

  programs.hyprlock = {
    enable = true;
    package = unstablePkgs.hyprlock;
  };

  environment.systemPackages = with pkgs; [
    # wayland tools
    wofi waybar swww.packages.${system}.swww customPackages.naga xdg-desktop-portal-gtk

    # Misc 
    gnome.gnome-settings-daemon gsettings-desktop-schemas
  ];

  custom.dotfiles = {
    enable = true;
    user = username;
    files = {
      hyprland = {
        text = builtins.readFile ../dotfiles/hyprland.conf;;
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
    };
  };

}
