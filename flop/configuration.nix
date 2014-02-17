{ config, pkgs, ... }:

{
  require = 
  [
    ../user-coconnor.nix
    ../coconnor-manages-nixos.nix
    ../java-dev.nix
    ../editorIsVim.nix
    ../standard-env.nix
    ../standard-packages.nix
    ../standard-services.nix
    ../filesystem.nix
    ../haskell-dev.nix
    ../i18n.nix
    ../kde4.nix
    ../vm-host.nix
    ./hardware-configuration.nix
  ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub =
  {
    enable = true;
    version = 2;
    device = "/dev/sda";
  };

  hardware.nvidiaOptimus.disable = true;
  boot.kernelPackages = pkgs.linuxPackages_3_12;

  networking =
  {
    hostName = "flop"; # Define your hostname.
    # networkmanager.enable = true;
    wireless =
    {
      enable = true;  # Enables wireless.
      userControlled.enable = true;
      interfaces = [ "wlp4s0" ];
    };
    extraHosts = ''
      192.168.1.142 toast
    '';
  };

  system.activationScripts =
  {
    configureAlsa = ''
      cp ${./asound.conf} /etc/asound.conf
    '';
  };

  # Enable the X11 windowing system.
  services.xserver =
  {
    enable = true;
    layout = "us";

    synaptics =
    {
      enable = true;
      twoFingerScroll = true;
      tapButtons = false;
      buttonsMap = [1 3 2];
      palmDetect = true;
      minSpeed = "1.5";
      maxSpeed = "100";
      accelFactor = "0.34";
      additionalOptions = ''
        Option "SHMConfig" "true"
        Option "FingerLow" "5"
        Option "FingerHigh" "20"
        Option "ConstantDeceleration" "20"
        Option "AdaptiveDeceleration" "20"
        Option "VertResolution" "62"
        Option "HorizResolution" "64"
        Option "HorizHysteresis" "1"
        Option "VertHysteresis" "1"
      '';
    };
  };
  services.xserver.desktopManager.kde4.enable = true;

  environment.systemConfigName = "flop/configuration.nix";
  environment.systemPackages = 
  [
    pkgs.xorg.xf86inputsynaptics
  ];
}
