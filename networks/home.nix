{config, pkgs, ...}:
{
  imports =
  [
    ./known-hosts.nix
    ../users/admin.nix
    ../users/boconnor.nix
    ../users/coconnor.nix
    ../users/jenkins.nix
    ../users/media.nix
    ../users/nix.nix
  ];

  config =
  {
    networking =
    {
      extraHosts = ''
        192.168.1.2 agh
        192.168.1.3 waffle
        192.168.1.4 ufo
        192.168.1.5 thrash
        192.168.1.6 alter
        192.168.1.7 grr
        192.168.1.8 kahn

        34.230.8.125 private
        34.233.199.132 public
        34.233.199.132 blog
        34.233.199.132 data
      '';
    };

    security.pki.certificateFiles = [ ./agh-0.crt ];
  };
}
