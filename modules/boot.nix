{ ... }:
{
  boot.loader.raspberry-pi.bootloader = "kernel";
  boot.tmp.cleanOnBoot = true;
  boot.tmp.useTmpfs = false;
  boot.tmp.tmpfsSize = 100;
}
