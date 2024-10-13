{ lib, pkgs, ... }:
{

  # need to disable wpa_supplicant since we use NM
  networking.wireless.enable = false;

  users.users.ian = {
    isNormalUser = true;
    packages = [ ];
    extraGroups = [ "wheel" "plugdev" "input" "docker" "networkmanager" "libvirtd" ];
  };


  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = lib.mkForce "${pkgs.hyprland}/bin/hyprland";
        user = lib.mkForce "ian";
      };
    };
  };

}
