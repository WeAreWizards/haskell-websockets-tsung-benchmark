let
    region = "eu-west-1";
    common-config = {
        networking.firewall.enable = false;
        networking.firewall.allowedTCPPorts = [ 22 8080 ];
        networking.firewall.allowPing = true;

        # ssh-keys
        users.extraUsers.root.openssh.authorizedKeys.keyFiles = [
            ./id_rsa_tom.pub
        ];
    };
in
rec {
    network.description = "haskell-websocket-test-setup";
    resources.ec2KeyPairs.pair =
        { inherit region; };
    resources.ec2SecurityGroups.http-ssh = {
        inherit region;
        rules = [
            { fromPort = 22; toPort = 22; sourceIp = "0.0.0.0/0"; }
            { fromPort = 8080; toPort = 8080; sourceIp = "0.0.0.0/0"; }
        ];
    };

    websock-server = { resources, pkgs, lib, config, ... }:
    let
        haskell-websock = pkgs.haskellPackages.callPackage ../code/default.nix {};
    in
        (common-config // {
        deployment.targetEnv = "ec2";
        deployment.ec2.region = region;
        deployment.ec2.instanceType = "m4.xlarge";
        deployment.ec2.spotInstancePrice = 10;

        deployment.ec2.keyPair = resources.ec2KeyPairs.pair;
        deployment.ec2.securityGroups = [ resources.ec2SecurityGroups.http-ssh ];

        environment.systemPackages = [ pkgs.vim ];
        require = [
          ./haskell-websock-module.nix
        ];

        services.haskell-websock.package = haskell-websock;

        boot.kernel.sysctl = {
          "fs.file-max" = 12000500;
          "fs.nr_open" = 20000500;
          "net.ipv4.tcp_mem" = "10000000 10000000 10000000";
          "net.ipv4.tcp_rmem" = "1024 4096 16384";
          "net.ipv4.tcp_wmem" = "1024 4096 16384";
          "net.core.rmem_max" = 16777216;
          "net.core.wmem_max" = 16777216;
          "net.ipv4.tcp_max_syn_backlog" = 4096;
          "net.core.somaxconn" = 4096;
          "net.core.netdev_max_backlog" = 2500;
          "vm.swappiness" = 0;
        };
    });

    # Find all public IPs in nixops state file:
    # select * from ResourceAttrs where name = "publicIpv4";
    tsung-1 = { resources, pkgs, lib, config, ... }:
    let
        tsung = pkgs.callPackage ./tsung.nix {};
    in
        (common-config // {
        deployment.targetEnv = "ec2";
        deployment.ec2.region = region;
        deployment.ec2.instanceType = "m4.xlarge";
        deployment.ec2.spotInstancePrice = 10;

        deployment.ec2.keyPair = resources.ec2KeyPairs.pair;
        deployment.ec2.securityGroups = [ resources.ec2SecurityGroups.http-ssh ];

        environment.systemPackages = [ pkgs.vim tsung pkgs.erlang pkgs.gnuplot ];

        boot.kernel.sysctl = {
          "fs.file-max" = 12000500;
          "fs.nr_open" = 20000500;
          "net.ipv4.tcp_mem" = "10000000 10000000 10000000";
          "net.ipv4.tcp_rmem" = "1024 4096 16384";
          "net.ipv4.tcp_wmem" = "1024 4096 16384";
          "net.core.rmem_max" = 16384;
          "net.core.wmem_max" = 16384;
          "net.ipv4.tcp_tw_reuse" = 1;
          "net.ipv4.tcp_tw_recycle" = 1;
          "net.ipv4.ip_local_port_range" = "1024 65000";
        };
    });
}
