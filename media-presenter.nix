{config, pkgs, ...}:
{
  require =
  [
    ./dependencies/retronix
    ./users/media.nix
    ./musnix
  ];

  retronix =
  {
    enable = true;
    user = "media";
  };

  musnix =
  {
    enable = false;
    kernel =
    {
      latencytop = true;
      optimize = true;
      realtime = true;
      # must match computer linuxPackages version
      # packages = pkgs.linuxPackages_4_17_rt;
    };
  };

  networking.firewall =
  {
    allowedTCPPorts = [ 8180 9090 ];
    allowedUDPPorts = [ 9777 ];
  };

  services.xserver.displayManager.slim =
  {
    enable = true;
    defaultUser = "media";
    autoLogin = true;
  };

  #services.xserver.desktopManager.kodi.enable = true;
  #services.xserver.desktopManager.default = "xterm";
  services.xserver.desktopManager.default = "retronix";

  services.xserver.windowManager.pekwm.enable = true;
  services.xserver.windowManager.default = "pekwm";
}
