{ ... }:
{
  environment.variables = {
    TERMINAL = "ghostty";
  };

  home-manager.sharedModules = [
    {

      programs.ghostty = {
        enable = true;

        settings = {
          font-size = 18;
          cursor-style = "block";
        };
      };
    }
  ];
}
