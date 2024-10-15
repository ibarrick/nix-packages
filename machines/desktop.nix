{ config, pkgs, unstablePkgs, ... }:
{
  imports = [
    ../hardware-configuration/desktop-generated.nix
    ../modules/gpg-secrets.nix
  ];

  boot.loader.efi.canTouchEfiVariables = true;
  
  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.loader.grub = {
	enable = true;
	version = 2;
	device = "nodev";
	efiSupport = true;
	enableCryptodisk = true;
	useOSProber = false;
    memtest86.enable = true;
    extraEntries = ''
    menuentry 'Windows Boot Manager (on /dev/nvme0n1p1)' --class windows --class os $menuentry_id_option 'osprober-efi-50D9-6952' {
        insmod part_gpt
        insmod fat
        search --no-floppy --fs-uuid --set=root 50D9-6952
        chainloader /efi/Microsoft/Boot/bootmgfw.efi
    }
    '';
  };

  # Need to use modern kernel for better support
  boot.kernelPackages = unstablePkgs.linuxPackages_latest;
  boot.kernelParams = [
     "nvidia-drm.modeset=1"
     "nvidia-drm.fbdev=1"
  ];

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = true;
    package = config.boot.kernelPackages.nvidiaPackages.beta; #pkgs.unstable.linuxPackages.nvidiaPackages.beta;
  };
  hardware.opengl.enable = true;

  networking.hostName = "nixos";

  users.users.ian = {
    isNormalUser = true;
    packages = [ ];
    extraGroups = [ "wheel" "plugdev" "input" "docker" "networkmanager" "libvirtd" ];
  };


  # for CPC stuff
  environment.unixODBCDrivers = with pkgs; [ unixODBCDrivers.msodbcsql17 ];

  environment.systemPackages = with pkgs; [
    unixODBCDrivers.msodbcsql17 unixODBC libiodbc
  ];

  services.gpg-secrets = {
    enable = true;
    gpgHome = "/home/ian/.gnupg";
    secrets = {
      restic-pw = {
        source = ../secrets/restic-pw.gpg;
        destination = "/var/run/nix-secrets/restic-pw";
        owner = "ian";
        group = "users";
        mode = "0400";
      };
      restic-env = {
        source = ../secrets/restic-env.gpg;
        destination = "/var/run/nix-secrets/restic-env";
        owner = "ian";
        group = "users";
        mode = "0400";
      };
    };
  };

  system.stateVersion = "20.09";

}
