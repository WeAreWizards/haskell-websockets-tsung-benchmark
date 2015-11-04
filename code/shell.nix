# Use Nix 15.09
with (import (fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixos-15.09.tar.gz) {}).pkgs;
(haskellPackages.callPackage ./. {}).env
