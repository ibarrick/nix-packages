{ pkgs, username, customPackages, ... }:
{

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  time.timeZone = "America/New_York";

  networking.resolvconf.enable = false;

  services.sshd.enable = true;
  services.tailscale.enable = true;
  services.mullvad-vpn.enable = true;
  services.avahi.enable = true;

  programs.gnupg.agent.enable = true;
  programs.ssh.startAgent = true;
  programs.mosh.enable = true;

  security.apparmor.enable = true;

  environment.systemPackages = with pkgs; [
    # Utils
    wget tmux lsof lesspass-cli rclone file utillinux jq glib exfat btop pasystray usbutils unzip git-annex

    # Devops
    awscli2 aws-vault lazygit git-lfs mycli git smug zprint

    # Applications
    gthumb bitwarden restic gpg-tui bitwarden-cli

    # neovim
    customPackages.neovim
    powerline-fonts
  ];

  custom.dotfiles = {
    enable = true;
    user = username;
    files = {
      bashrc = {
        text = ''
          export AWS_VAULT_BACKEND=file
          export BROWSER=chromium
          export EDITOR=nvim
          if [ ! -f /run/secrets/bw-session ]; then
             bw unlock --raw > /run/secrets/bw-session
          fi
        '';
        target = ".bashrc";
      };
      profiles = {
        text = builtins.readFile ../dotfiles/profiles.clj;
        target = ".lein/profiles.clj";
      };
      tmux = {
        text = builtins.readFile ../dotfiles/tmux.conf;
        target = ".tmux.conf";
      };
      gitconfig = {
        text = ''
          [user]
	email = "ian@servisuite.com"
          name = "Ian Barrick"
        '';
        target = ".config/git/config";
      };
    };
  };


}
