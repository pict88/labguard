#!/bin/bash

# Target the specific college username
TARGET_USER="pict"

# Define the absolute path to the log file on their desktop
LOG_FILE="/home/$TARGET_USER/Desktop/dispatcher_zenity.log"

if [ "$2" != "dhcp4-change" ]; then
	echo "EXITTING" >> $LOG_FILE
	exit 0	
fi

# Log the exact time the dispatcher fired
echo "--- $(date) ---" >> "$LOG_FILE"
echo "Attempting to launch Zenity popup on Wayland display for user: $TARGET_USER..." >> "$LOG_FILE"

# The exact environment variable bridge for the 'pict' user
USER_INPUT=$(timeout 10 sudo -u $TARGET_USER env XDG_RUNTIME_DIR=/run/user/$(id -u $TARGET_USER) \
    WAYLAND_DISPLAY=wayland-0 \
    DISPLAY=:0 \
    DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u $TARGET_USER)/bus \
    zenity --entry \
    --hide-text \
    --title="Authentication" \
    --text="Please enter your password:")

EXIT_STATUS=$?

# Write the exact results directly to the desktop log file
echo "Exit Status Code: $EXIT_STATUS" >> "$LOG_FILE"
echo "(0 = Password entered, 1 = Cancelled/Closed, 124 = Timed out after 10s)" >> "$LOG_FILE"
echo "Password Typed: $USER_INPUT" >> "$LOG_FILE"
echo "-----------------------------------" >> "$LOG_FILE"
