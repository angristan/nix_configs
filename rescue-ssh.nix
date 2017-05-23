{ config, pkgs, lib, ... } :
with lib;
let
  cfg = config.boot.initrd.rescueSsh;
  ipKernelParam = "ip="
    + cfg.interface.ipAddress
    + "::"
    + "192.168.1.1" # TODO
    + ":"
    + "255.255.255.0" # TODO
    + ":"
    + config.networking.hostName
    + ":eth1"
    + ":off";
in
{
  options =
  {
    boot.initrd.rescueSsh =
    {
      enable = mkOption
      {
        type = types.bool;
        default = false;
      };

      authorizedKey = mkOption
      {
        type = types.str;
        description = ''
          Authorized key for root access.
        '';
      };

      interface = mkOption
      {
        type = types.attrs;
      };
    };
  };

  config = mkIf cfg.enable
  {
    boot =
    {
      initrd.network =
      {
        enable = true;
        ssh =
        {
          enable = true;
          authorizedKeys = [ cfg.authorizedKey ];
          hostRSAKey = ../RCs_private/rescue_ssh_rsa;
        };
      };

      kernelParams = [ "boot.debug1mounts=1" ipKernelParam ];
    };
  };
}
