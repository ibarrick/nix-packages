{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.gpg-secrets;
in
{
  options.services.gpg-secrets = {
    enable = mkEnableOption "GPG secrets decryption service";

    secrets = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          source = mkOption {
            type = types.path;
            description = "Path to the encrypted GPG file";
          };
          destination = mkOption {
            type = types.str;
            description = "Path where the decrypted file should be symlinked";
          };
          owner = mkOption {
            type = types.str;
            default = "root";
            description = "Owner of the decrypted file";
          };
          group = mkOption {
            type = types.str;
            default = "root";
            description = "Group of the decrypted file";
          };
          mode = mkOption {
            type = types.str;
            default = "0400";
            description = "Permissions of the decrypted file";
          };
        };
      });
      default = {};
      description = "Attribute set of secrets to decrypt";
    };

    gpgHome = mkOption {
      type = types.str;
      default = "/root/.gnupg";
      description = "Path to the GPG home directory";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.gpg-secrets = {
      description = "Decrypt GPG secrets";
      wantedBy = [ "multi-user.target" ];
      before = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };

      script = let
        secretsDir = "/run/secrets";
      in ''
        mkdir -p ${secretsDir}
        chmod 777 ${secretsDir}
        ${concatStringsSep "\n" (mapAttrsToList (name: secret: ''
          mkdir -p $(dirname ${secretsDir}/${name})
          ${pkgs.gnupg}/bin/gpg --quiet --yes --no-tty --pinentry-mode loopback --homedir ${cfg.gpgHome} --decrypt ${toString secret.source} > ${secretsDir}/${name}
          chown ${secret.owner}:${secret.group} ${secretsDir}/${name}
          chmod ${secret.mode} ${secretsDir}/${name}
          mkdir -p $(dirname ${secret.destination})
          ln -sf ${secretsDir}/${name} ${secret.destination}
          chown -h ${secret.owner}:${secret.group} ${secret.destination}
          chmod -h ${secret.mode} ${secret.destination}
        '') cfg.secrets)}
      '';
    };

    systemd.services.gpg-secrets-cleanup = {
      description = "Clean up decrypted GPG secrets";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        rm -rf /run/secrets
      '';
    };
  };
}
