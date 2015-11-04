{ mkDerivation, base, bytestring, stdenv, stm, unagi-chan, wai
, wai-websockets, warp, websockets
}:
mkDerivation {
  pname = "haskell-websock";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  buildDepends = [
    base bytestring stm unagi-chan wai wai-websockets warp websockets
  ];
  description = "Example showing how to use websockets and warp";
  license = stdenv.lib.licenses.gpl3;
}
