let
  viva = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILV1M/5M3gI/UpR1OR/zRAe3Eg03UYZDk2EptG78L14k nan0br3aker@gmail.com";
  cb1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK7n/1xObjvGeJNh3Hk/MosWkoTlttV5Z1vCNNjA9Xj+ root@computeblade1";

  blades = [
    cb1
  ];
in
{
  "opentelemetry.age".publicKeys = [
    viva
  ]
  ++ blades;
}
