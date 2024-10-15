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

  environment.systemPackages = with pkgs; [
    unixtools.fsck wipe nwipe ntfs3g nmap parted gparted socat paperkey

    testdisk safecopy sleuthkit ddrescue

    # Exploitation
    metasploit exploitdb social-engineer-toolkit sqlmap routersploit ropgadget pwntools pwndbg gef crackmapexec

    # Bruteforcing
    thc-hydra hashcat hashcat-utils pdfcrack rarcrack truecrack 

    # Enumeration
    wfuzz gobuster dirb snmpcheck nikto enum4linux-ng smbscan dnsenum 
    termshark 

    # MITM 
    bettercap mitmproxy 
  ];
}
