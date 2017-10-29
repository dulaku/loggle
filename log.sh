#!/bin/bash

#Ideas stolen freely from https://www.contextis.com/blog/logging-like-a-lumberjack
#Prerequisite Steps:
#Add timestamps to terminal prompt by replacing PS1 in .bashrc with
#  PS1='[`date  +"%d-%b-%y %T"`] > '
#  If you don't use the IP-recording variant, it's recommended that you run ifconfig after starting the logs
#  Check for a segment of .bashrc that reads something like:
#  case "$TERM" in
#  xterm*|rxvt*)
#      PS1="\[\e]0;${debian_chroot:+(#debian_chroot)}\u@\h: \w\a\]$PS1"
#      ;;
#  *)
#      ;;
#  #esac
#and comment it out. This will stop bash from overwriting your new terminal title.
#Ensure you can run tcpdump without root privileges by
#  sudo groupadd pcap
#  sudo usermod -a -G pcap $USER
#  sudo chgrp pcap /usr/sbin/tcpdump
#  sudo chmod 750 /usr/sbin/tcpdump
#  sudo chmod +x /usr/sbin/tcpdump
#  sudo setcap cap_net_raw,cap_net_admin=eip /usr/sbin/tcpdump
#Give Wireshark the ability to decrypt TLS traffic from Chromium/Firefox by
#adding to .bashrc
#  export SSLKEYLOGFILE=/path/to/sslkeys.log
#Then point Wireshark at it under Edit>Preferences>Protocols>SSL>(Pre)-Master-Secret log filename

if [ $# -lt 2 ]; then
	echo "Requires a client, followed by a list of IP addresses to monitor."
	exit
fi
client="$1"

export PROMPT_COMMAND='echo -en '"\"\033]0; $client Testing\a\""

ips=0
if [ $# -gt 2 ]; then
	ips=1
	shift #Ignore the client argument in future steps
	filter="host $1"
	shift #Got the first IP
	for i in "$@"
	do
		filter+=" or host "
		filter+="$i"
	done

	if [ ! -d "$HOME/Testing" ]; then
		mkdir $HOME/Testing
	fi
	if [ ! -d "$HOME/Testing/$client" ]; then
		mkdir $HOME/Testing/$client
	fi
	if [ ! -d "$HOME/Testing/$client/logs" ]; then
		mkdir $HOME/Testing/$client/logs
	fi

	/usr/sbin/tcpdump -i eth0 -tt -vv -nn --no-promiscuous-mode -s 65535 -w $HOME/Testing/$client/logs/$(date +"%d-%b-%y_%H-%M-%S")_packets.pcap $filter > /dev/null 2>&1 &
	tdpid=$!
fi

test "$(ps -ocommand= -p $PPID | awk '{print $1}')" == 'script' || (script -f $HOME/Testing/$client/logs/$(date +"%d-%b-%y_%H-%M-%S")_shell.log)
if [ $ips -eq 1 ]; then
	kill $tdpid
fi
