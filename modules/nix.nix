_: {
  nix.settings = {
    trusted-users = [
      "nixos"
      "root"
      "thatwhichisapple"
    ];

    experimental-features = [
      "nix-command"
      "flakes"
    ];

    download-buffer-size = 268435456;
  };
}
