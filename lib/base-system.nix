{ pkgs, username, customPackages, ... }:
{

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  time.timeZone = "America/New_York";

  networking.resolvconf.enable = false;

  services.sshd.enable = true;
  services.tailscale.enable = true;

  programs.gnupg.agent.enable = true;
  programs.ssh.startAgent = true;
  programs.mosh.enable = true;

  security.apparmor.enable = true;

  environment.systemPackages = with pkgs; [
    # Utils
    wget tmux lsof lesspass-cli rclone file utillinux jq glib exfat btop pasystray

    # Devops
    awscli2 aws-vault lazygit git-lfs mycli git 

    # Applications
    gthumb bitwarden restic 

    # neovim
    customPackages.neovim
  ];

  custom.dotfiles = {
    enable = true;
    user = username;
    files = {
      bashrc = {
        text = ''
          export AWS_VAULT_BACKEND=file
          export BROWSER=chromium
          export EDITOR=vim
        '';
        target = ".bashrc";
      };
      profiles = {
        text = builtins.readFile ../dotfiles/profiles.clj;
        target = ".lein/profiles.clj";
      };
    };
  };


}
