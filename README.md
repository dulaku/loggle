# loggle

Ideas stolen freely from https://www.contextis.com/blog/logging-like-a-lumberjack <br>

### Usage:
```
log.sh <log subject> <IP Addr 1> <IP Addr 2> ... <IP Addr N>
```

When run, outputs a log (using `script`) of terminal activity into `~/Testing/<log subject>`. If any IP addresses are supplied, also uses `tcpdump` to capture a log of packets between your machine and any of the supplied addresses, and saves the resulting pcap to the same directory. All this assumes you're running debian and bash, so some tweaking may be necessary for your use case.

### Prerequisites: <br>
```
tcpdump
script
```

### Recommended: <br>
```
wireshark
chromium or firefox as primary browser
```

Add timestamps to terminal prompt by replacing PS1 in .bashrc with<br>
```
PS1='[`date  +"%d-%b-%y %T"`] > '
```
This snippet displays timestamps only - the linked article includes a variant that displays IP addresses, which may be more convenient for you. If you use this version, consider running `ifconfig` as your first command so you get that information logged.

Check for a segment of .bashrc that reads something like:
```
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+(#debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac
```
and comment it out if you find it. This will stop bash from overwriting your new terminal title.<br>

Ensure you can run tcpdump without root privileges by <br>
```
sudo groupadd pcap
sudo usermod -a -G pcap $USER
sudo chgrp pcap /usr/sbin/tcpdump
sudo chmod 750 /usr/sbin/tcpdump
sudo chmod +x /usr/sbin/tcpdump
sudo setcap cap_net_raw,cap_net_admin=eip /usr/sbin/tcpdump
```
Give Wireshark the ability to decrypt TLS traffic from Chromium/Firefox by adding to .bashrc <br>
```export SSLKEYLOGFILE=/path/to/sslkeys.log``` <br>
Then point Wireshark at it under Edit>Preferences>Protocols>SSL>(Pre)-Master-Secret log filename
