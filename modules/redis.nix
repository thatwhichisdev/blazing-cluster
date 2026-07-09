{ pkgs, ... }:
{

  services.redis = {
    package = pkgs.redis;
    servers."" = {
      enable = true;
      port = 6379;
      openFirewall = true;
    };
  };
}
