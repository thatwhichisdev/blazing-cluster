{ pkgs, ... }:
{

  environment.systemPackages = [ pkgs.gitui ];

  home-manager.sharedModules = [
    {
      programs.git = {
        enable = true;
        settings = {
          core.editor = "hx";
          user.name = "nanobreaker";
          user.email = "nan0br3aker@gmail.com";
        };
      };
    }
  ];
}
