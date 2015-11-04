# install locally:
# nix-env -i $(nix-instantiate -E 'with (import <nixpkgs> {}); callPackage ./nix/tsung.nix {}')
{stdenv, fetchurl, erlang, pam, perl }:

stdenv.mkDerivation rec {
  name = "tsung-${version}";
  version = "1.6.0";

  src = fetchurl {
    url = "http://tsung.erlang-projects.org/dist/${name}.tar.gz";
    sha256 = "111xxchbdc5x3vpycbqy952868sj627wnc33lzckfw7xj0x6r12n";
  };
  patches = [ ./maxproc.patch ];

  buildInputs = [ erlang pam perl ];

  meta = with stdenv.lib; {
    description = "Tsung is an open-source multi-protocol distributed load testing tool";
    homepage = http://tsung.erlang-projects.org/;
    license = licenses.gpl2;
    platforms = platforms.linux;
  };
}
