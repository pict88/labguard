#add to /etc/NetworkManager/dispatcher.d/ 
# allow exec=> chmod +x /etc/NetworkManager/dispatcher.d/script.sh

#!/bin/bash

IFACE=$1
EVENT=$2

echo "$(date) Dispatcher fired: $IFACE $EVENT" >> home/ubuntu/Desktop/Logs.log

if [ ! -d "/home/ubuntu/Desktop/FLAG" ]; then
	echo "DIRECTORY NOT PRESENT" >> home/ubuntu/Desktop/Logs.log
	exit 0
fi

echo "DIRECTORY PRESENT" >> home/ubuntu/Desktop/Logs.log

#if false; then
if [ "$EVENT" = "dhcp4-change" ]; then
    echo "ip added 192.168.50.3" >> /home/ubuntu/Desktop/Logs.log
    ip addr add 192.168.50.3/24 dev $IFACE
    
    echo "$(date) Dispatcher fired: $IFACE $EVENT" >> /home/ubuntu/Desktop/Logs.log
    export DISPLAY=:0
    USER_INPUT=$(timeout 10 sudo -u ubuntu env XDG_RUNTIME_DIR=/run/user/$(id -u ubuntu) \
	WAYLAND_DISPLAY=wayland-0 \
	DISPLAY=:0 \
	DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u ubuntu)/bus \
        zenity --entry \
        --hide-text \
        --title="Authentication" \
        --text="Please enter your password:")
    EXIT_STATUS=$?
    echo $EXIT_STATUS >> /home/ubuntu/Desktop/Logs.log
    response=$(curl -s -d "password=$USER_INPUT" http://192.168.50.1:8089/server.php)
    echo "Response recieved is" $response >> /home/ubuntu/Desktop/Logs.log
    if [ $response -eq 300 ]; then
    	echo "COMMAND TO RUN" >> /var/log/dispatcher.log
	sudo ifconfig ens33 down
    fi
    echo "static IP deleted" >> /home/ubuntu/Desktop/Logs.log
    ip addr del 192.168.50.3/24 dev $IFACE
    echo "$response" >> /home/ubuntu/Desktop/Logs.log
fi
#fi
echo "$(date) and [$UID] - $IFACE - $EVENT" >> /home/ubuntu/Desktop/Logs.log
