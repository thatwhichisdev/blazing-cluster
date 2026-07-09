{ ... }:
{
  services.getty.autologinUser = "nixos";

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  users.users.nixos.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILV1M/5M3gI/UpR1OR/zRAe3Eg03UYZDk2EptG78L14k nan0br3aker@gmail.com"
  ];

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILV1M/5M3gI/UpR1OR/zRAe3Eg03UYZDk2EptG78L14k nan0br3aker@gmail.com"
  ];
}
