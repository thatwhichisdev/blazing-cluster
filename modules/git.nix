{ pkgs, ... }:
{

  environment.systemPackages = [ pkgs.gitui ];

  home-manager.sharedModules = [
    {
      programs.git = {
        enable = true;
        settings = {
          core.editor = "hx";
          user.name = "thatwhichisdev";
          user.email = "eager@thatwhichis.dev";
        };
      };
    }
  ];
}
