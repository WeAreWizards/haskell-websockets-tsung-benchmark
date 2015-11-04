# Haskell can be fast, too

*Reading time: ~20 minutes.*

I really enjoyed reading how the phoenix-framework people managed to
get to
[two million active websocket connections](http://www.phoenixframework.org/v1.0.0/blog/the-road-to-2-million-websocket-connections).

I've heard some very smart people say that Haskell has an amazing
runtime with very cheap threads. I have no reason to disbelieve them
but we thought it'd be fun to see how it fares with websockets.

PELICAN END

Unlike the Phoenix people didn't have Rackspace sponsorship so we had
to resort to the common man's cheap machines: EC2 spot instances. We
bid $0.10 on two `m4.xlarge` machines with 16G of RAM and 4 cores
which are usually 4-5 cents in eu-west.

We're using Nix to deploy tsung and a very simple Haskell chat program
that just broadcasts messages to everyone.

```
nixops create '<nix/test-setup.nix>'
nixops deploy
```



```
ip addr add 172.31.23.115/20 dev eth0
ip addr add 172.31.23.113/20 dev eth0
ip addr add 172.31.23.114/20 dev eth0
ip addr add 172.31.23.112/20 dev eth0

ip addr add 172.31.18.80/20 dev eth0
ip addr add 172.31.18.81/20 dev eth0
ip addr add 172.31.18.82/20 dev eth0
ip addr add 172.31.18.83/20 dev eth0
```

nixops scp --to tsung-1 code/src/tsung-conf.xml tsung-conf.xml

# keeping track of the stats

$ ssh root@52.31.104.126 -L 8091:127.0.0.1:8091

# running

export PATH=${PATH}:/nix/store/jf5axwnf5lymj96dsgbgz5pqlzbyshs9-tsung-1.6.0/lib/tsung/bin/


tsung -f tsung-conf.xml start
Starting Tsung
Log directory is: /root/.tsung/log/20151104-1622

# firewalls

[ 2960.570157] nf_conntrack: table full, dropping packet
[ 2960.575060] nf_conntrack: table full, dropping packet
[ 2960.629764] nf_conntrack: table full, dropping packet
[ 2960.678016] nf_conntrack: table full, dropping packet
[ 2992.936177] TCP: request_sock_TCP: Possible SYN flooding on port 8080. Sending cookies.  Check SNMP counters.
[ 2998.005969] net_ratelimit: 364 callbacks suppressed


[root@websock-server:~]# netstat -ntp  | grep -v TIME_WAIT | wc
 119748  838238 12094489


# adjust number of processes:

=ERROR REPORT==== 4-Nov-2015::18:03:45 ===
Too many processes

Add `-p`:

tsung -p 1250000 -f tsung-conf.xml start


# 100k users

  PID USER      PR  NI    VIRT    RES    SHR S  %CPU %MEM     TIME+ COMMAND
 1944 root      20   0 7210960 2.656g  22524 S 177.7 16.9   2:58.50 haskell-websock



Internal Server Error

# MAX_PROCESS

https://github.com/processone/tsung/issues/136


# Finally


 2252 root      20   0 11.237g 4.714g  22532 S 128.3 30.1   6:58.25 haskell-websock



[root@websock-server:~]# netstat -ntp  | grep -v TIME_WAIT | wc -l
198035


# getting more addresses to work around 64k limit:

eni-5af8fa3d: Number of private addresses will exceed limit.


```
ip addr add 172.31.26.100/20  dev eth0
ip addr add 172.31.26.99/20  dev eth0
ip addr add 172.31.18.106/20  dev eth0
ip addr add 172.31.30.220/20  dev eth0
ip addr add 172.31.18.240/20  dev eth0
ip addr add 172.31.30.188/20  dev eth0
```

We have 15 addresses in total:

>>> 15 * 64000
960000

# now the benchmarker needs more memory:

```
/run/current-system/sw/bin/tsung: line 60: 29721 Killed                  [...]
```

haskell still quite comfortably at 10G:

```
  PID USER      PR  NI    VIRT    RES    SHR S  %CPU %MEM     TIME+ COMMAND
 2320 root      20   0 16.879g 9.395g  22300 S   0.0 59.9  14:38.75 haskell-websock
```

# time to clean up

$ nixops destroy
warning: are you sure you want to destroy EC2 machine ‘tsung-1’? (y/N) y
warning: are you sure you want to destroy EC2 machine ‘websock-server’? (y/N) y
