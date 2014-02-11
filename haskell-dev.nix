{ config, pkgs, ... } :

with pkgs.lib;

{
  nixpkgs.config.packageOverrides = in_pkgs : rec
  { 
    haskellPackages = in_pkgs.haskellPackages_ghc763;
    hsEnv = in_pkgs.haskellPackages.ghcWithPackages (self : [
      # self.ghcPlain
      self.ghcPaths
      self.Cabal_1_16_0_3 
      self.async_2_0_1_4
      # self.cgi_3001_1_8_4
      self.fgl_5_4_2_4
      self.GLUT_2_3_1_0
      self.GLUT_2_3_1_0
      self.haskellSrc_1_0_1_5
      self.html_1_0_1_2
      self.HTTP_4000_2_8
      self.HUnit_1_2_5_1
      self.mtl_2_1_2
      self.network_2_4_1_2
      self.OpenGL_2_6_0_1
      self.parallel_3_2_0_3
      self.parsec_3_1_3
      self.QuickCheck_2_5_1_1
      self.random_1_0_1_1
      self.regexBase_0_93_2
      self.regexCompat_0_95_1
      self.regexPosix_0_95_2
      self.split_0_2_1_1
      self.stm_2_4_2
      self.syb_0_3_7
      self.text_0_11_2_3
      self.terminfo
      self.transformers_0_3_0_0
      self.vector_0_10_0_1
      self.xhtml_3000_2_1
      self.zlib_0_5_4_0
      self.cabalInstall_1_16_0_2
      self.alex_3_0_5
      # self.haddock_2_13_2
      self.happy_1_18_10
      self.primitive_0_5_0_1
      self.X11
      self.X11Xft
      self.xmonad
      self.xmonadContrib
      self.xmonadExtras
      self.pandoc
    ]);
  };

  nixpkgs.config.cabal.libraryProfiling = true;

  environment.systemPackages = 
  [ pkgs.hsEnv
  ];
}

