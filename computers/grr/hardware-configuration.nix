# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ "ehci_pci" "ahci" "mpt3sas" "xhci_pci" "usbhid" "usb_storage" "sd_mod" "sr_mod" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "rpool/root/grr-1";
      fsType = "zfs";
    };

  fileSystems."/home" =
    { device = "rpool/home";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/bea4ca24-f511-45eb-b979-3d9d7137079e";
      fsType = "ext4";
    };

  swapDevices =
  [
    #{ device = "/dev/zvol/rpool/swap"; }
  ];

  nix.maxJobs = 3;
  nix.extraOptions = ''
    build-cores = 5
  '';

  security.pam.loginLimits =
  [
    {
      domain = "*";
      type = "soft";
      item = "nproc";
      value = "unlimited";
    }
  ];
}
