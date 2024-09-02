{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.naga;
in {
  options.services.naga = {
    enable = mkEnableOption "Razer Naga Key Modifier Service";

    package = mkOption {
      type = types.package;
      default = pkgs.callPackage ../naga/default.nix {};
      defaultText = "pkgs.callPackage ./default.nix {}";
      description = "The Razer Naga Key Modifier package to use.";
    };

    user = mkOption {
      type = types.str;
      default = "nobody";
      description = "The user to run the Razer Naga Key Modifier service.";
    };

    group = mkOption {
      type = types.str;
      default = "input";
      description = "The group to run the Razer Naga Key Modifier service.";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.naga = {
      description = "Razer Naga Key Modifier Service";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/naga";
        Restart = "always";
        RestartSec = 5;
        User = cfg.user;
        Group = cfg.group;

        path = [ cfg.package pkgs.hyprland ];

        # Hardening measures
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        NoNewPrivileges = true;
        ProtectKernelTunables = true;
        ProtectControlGroups = true;
        ProtectKernelModules = true;
        RestrictAddressFamilies = "AF_UNIX AF_NETLINK AF_INET AF_INET6";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        MemoryDenyWriteExecute = true;

        # Allow access to input devices
        DeviceAllow = "/dev/input/event*";
        SupplementaryGroups = [ "input" ];
      };
    };

    # Ensure the input group exists
    users.groups.input = {};

    # Add the specified user to the input group
    users.users.${cfg.user}.extraGroups = [ "input" ];
  };
}
