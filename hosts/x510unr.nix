# Asus X510UNR — Ubuntu laptop that doubles as an always-on home server.
{
  my.homeServer = {
    enable = true;
    batteryChargeLimit = 80;   # lives on AC; don't sit at 100%
    zram.percent = 50;         # 7 GB RAM: compressed swap before the disk swapfile
  };
}
