{ pkgs, ... }:
{
  environment.variables = {
    TERMINAL = "ghostty";
  };

  environment.systemPackages = with pkgs; [
    ghostty.terminfo
  ];

}
