# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  require =
  [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../editorIsVim.nix
    ../../java-dev.nix
    ../../jenkins-node.nix
    ../../i18n.nix
    ../../networks/home.nix
    ../../rescue-ssh.nix
    ../../standard-env.nix
    ../../standard-nixpath.nix
    ../../standard-services.nix
    ../../tobert-config.nix
    ../../vm-host.nix
  ];

  nixpkgs.config.packageOverrides = in_pkgs :
  {
    linuxPackages = in_pkgs.linuxPackages_4_10;
  };

  vmhost =
  {
    type = "libvirtd";
    vfio =
    {
      enable = true;
      iommu = "intel";
      nvidiaBinds = [ "10de:17c8" "10de:0fb0" ];
      forceBinds = [ "0000:08:00.0" ];
      bootBinds = [ "13f6:8788" ];
    };
  };

  # grub bootloader installed to all devices in the boot raid1 array
  boot =
  {
    initrd =
    {
      rescueSsh =
      {
        enable = true;
        authorizedKey = ''
ssh-dss AAAAB3NzaC1kc3MAAACBAKE7zYw8MIbB3flIwtd2ze9nm9ASQJAy03FO/6OpfKZXONZOAVL574N2i8XF5BFHIrsCr/60N4BxaIkDfyQ6wSjl35th510s3fKeXUx9g0HEcZURmORD6n9An0VjXPLwepBioUE//P7okx3G24mHUk5XZsdF9st6hN6q9GeMn7aDAAAAFQC83NG9WE1z1++VbggfOmvsmimVMQAAAIAV2gOmt5NFo0MmWSveZk0QMIGfNPHE6dttYaJFajSDYRaZvh++KswR1logb+hKrI9m0NirWUi6rorZ8wM1rmaY5oZ46T4wa0y51tdRP9nt7eqpOI2bfyiF/+Y6QKjUuP8LUspRsuzK8V5cdXEGrBMKFRrFOQl5JtuGCiW3cl3rzQAAAIEAjV9/rTin43BOQNQ3473Wv3ldfXMrn+4g55vKZVpUfYmFSi6aEpTh7fCypoZqEhl2/rlRFwxIZkOlwce45up2s9ldAPVjUZHvBRWgjhXRsbjRjEe12m9BqmlDjy9qS6zZ16KHaNT1enXTwoS+o/NnGH6dqcuL1tWcDTVOBCI0k5I= coconnor@toast
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCyDmeCXPy8SYUJtgd8/7UV5TTHt7HxVwVF/OFFNBBTYvQ8AelZG88GQlY4kNRfltiAzFNbr5pgyGpfwpduWR7XU3AmgJaE/7CtejWzoC+uFss3cxxznM1NUs/OXNyizcwtXEucoKA6Ae3579j2mRuq81eAu3cCIS6NnYvTS5nYhqcFhHQm5ekKUIvhoWD9SV+yQhN9+rhag0bcUaOOMnHryScGIJ0qgXLZT2aeEtzsffQFo7KxLWIcHrd54oXWH2AMmn9Afjo4ZF5DHbmgk2FROEdOJIwTOV5KPdUeAgB+Od/vyGWSrPh55JrKYINh8ch8OuzW8iRzOtWGu55iyN8R coconnor@flop
        '';
        interface = config.networking.interfaces.enp9s0;
      };
    };

    kernelParams = [ "kvm-intel.nested=1" ];
    kernelPackages = pkgs.linuxPackages_4_10;

    loader.grub =
    {
      enable = true;
      version = 2;
      devices =
      [
        "/dev/disk/by-id/ata-ADATA_SP550_2G0420001801"
        "/dev/disk/by-id/ata-ADATA_SP550_2G0420002543"
        "/dev/disk/by-id/ata-ADATA_SP550_2G0420003186"
        "/dev/disk/by-id/ata-ADATA_SP550_2G0420001635"
        "/dev/disk/by-id/ata-ADATA_SP550_2G3220055024"
        "/dev/disk/by-id/ata-ADATA_SP550_2G3220055124"
      ];
      zfsSupport = true;
    };
  };

  networking =
  {
    hostId = "34343134";
    hostName = "grr"; # must be unique
    useDHCP = false;
    interfaces.enp9s0 =
    {
      ipAddress = "192.168.1.7";
      prefixLength = 24;
    };
    defaultGateway = "192.168.1.1";
    nameservers = [ "8.8.8.8" "8.8.4.4" ];
  };

  nix.trustedBinaryCaches = ["http://hydra.nixos.org"];

  services.openssh.extraConfig = ''
    UseDNS no
  '';

  services.journald.console = "/dev/tty12";

  system.stateVersion = "16.03";

  boot.kernel.sysctl =
  {
    "vm.nr_hugepages" = 16384;
  };

  systemd.services.windows-vm =
  {
    enable = false;
    description = "starts windows desktop.";
    after = [ "vfio-force-binds.service" ];
    wantedBy = [ "multi-user.target" ];
    restartIfChanged = false;
    serviceConfig =
    {
      Type = "simple";
    };
    # -drive file=/dev/zvol/rpool/root/waffle-1,format=raw,cache=writeback,aio=native,cache.direct=on \

    script = ''
    ${pkgs.numactl}/bin/numactl -N 0 \
      ${pkgs.qemu_kvm}/bin/qemu-kvm -m 24G -mem-path /dev/hugepages -M q35 \
        -cpu host,kvm=off,hv_time,hv_relaxed,hv_vapic,hv_spinlocks=0x1fff,hv_vendor_id=none \
        -smp 16,sockets=1,cores=8,threads=2 \
        -rtc base=localtime \
        -drive file=/dev/zvol/rpool/root/waffle-1,format=raw \
        -device ioh3420,bus=pcie.0,addr=1c.0,multifunction=on,port=1,chassis=1,id=root.1 \
        -device vfio-pci,multifunction=on,x-vga=on,host=05:00.0,bus=root.1,addr=00.0 \
        -device vfio-pci,host=05:00.1,bus=root.1,addr=00.1 \
        -device vfio-pci,host=08:00.0 -net none \
        -device vfio-pci,host=04:04.0 \
        -usbdevice host:045e:028e \
        -usbdevice host:047d:2041 \
        -usbdevice host:045e:000b \
        -usbdevice host:046d:0994 \
        -usbdevice host:054c:05c4 \
        -usbdevice host:1a40:0101 \
        -usbdevice host:04b9:0300 \
        -usbdevice host:058f:9410 \
        -usbdevice host:05f3:0007 \
        -usbdevice host:05f3:0081 \
        -usbdevice host:5332:1300 \
        -usbdevice host:2b24:0001 \
        -vga none -nographic
    '';
  };

  #services.xserver =
  #{
  #  enable = true;
  #  resolutions = [ { x = 2560; y = 1080; } ];
  #};
  services.xserver.displayManager.xpra.enable = true;
  networking.firewall =
  {
    allowedTCPPorts = [ 10000 ];
  };

  #services.xspice =
  #{
  #  enable = true;
  #  layout = "us";
  #  resolutions = [ { x = 2560; y = 1080; } ];
  #};
}
