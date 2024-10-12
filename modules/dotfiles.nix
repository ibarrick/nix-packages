{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.dotfiles;
in {
  options.custom.dotfiles = {
    enable = mkEnableOption "custom dotfiles management";

    user = mkOption {
      type = types.str;
      description = "The user for whom to manage dotfiles";
    };

    files = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          text = mkOption {
            type = types.str;
            description = "The content of the dotfile";
          };
          target = mkOption {
            type = types.str;
            description = "The target path for the symlink, relative to the user's home directory";
          };
        };
      });
      default = {};
      description = "An attribute set of dotfiles to manage";
    };
  };

  config = mkIf cfg.enable {
    system.activationScripts.userDotfiles = ''
      echo "Setting up dotfiles for ${cfg.user}..."
      
      USER_HOME="/home/${cfg.user}"
      mkdir -p "$USER_HOME"
      ${concatStringsSep "\n" (mapAttrsToList (name: file: ''
        echo "Setting up ${name}..."
        mkdir -p "$(dirname "$USER_HOME/${file.target}")"
        echo "Writing file to $USER_HOME/${file.target}"
        ln -sf "${pkgs.writeText name file.text}" "$USER_HOME/${file.target}"
        chown ${cfg.user}:users $(dirname "$USER_HOME/${file.target}")
        chown -h ${cfg.user}:users $USER_HOME/${file.target}
      '') cfg.files)}
    '';
  };
}
