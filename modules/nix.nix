{ ... }: {
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" "pipe-operators" ];
    substituters = [ "https://nixos-raspberrypi.cachix.org" ];
    trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
    trusted-users = [ "root" "nixos" ];
    download-buffer-size = 268435456;
  };
}
