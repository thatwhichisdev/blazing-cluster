{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    btop
    fastfetch
    pstree
    ripgrep
    systemctl-tui
    uutils-coreutils-noprefix
    usbutils
  ];
}
