{ ... }:
{
  boot.loader.raspberry-pi.firmwarePath = "/boot/firmware";
  boot.loader.raspberry-pi.bootloader = "kernel";
  boot.tmp.useTmpfs = false;
  boot.tmp.tmpfsSize = 100;
  boot.tmp.cleanOnBoot = true;
}
