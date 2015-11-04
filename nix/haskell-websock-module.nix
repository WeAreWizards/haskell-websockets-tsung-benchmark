{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.services.haskell-websock;
in
{
  options = {
    services.haskell-websock = rec {
      package = mkOption {
        type = types.package;
        default = null;
        description = "the package";
      };
    };
  };

  config = {
    systemd.services."haskell-websock" = {
      wantedBy = [ "multi-user.target" ];
      requires = [ "network.target" ];
      after = [ "network.target" ];

      serviceConfig.LimitNOFILE = 20000000;
      serviceConfig.ExecStart = "${cfg.package}/bin/haskell-websock";
    };
  };
}
