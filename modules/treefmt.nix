{ pkgs, ... }:
{
  projectRootFile = "flake.nix";

  programs.nixfmt = {
    enable = true;
    package = pkgs.nixfmt;
  };

  programs.deadnix.enable = true;
  programs.statix.enable = true;
}
