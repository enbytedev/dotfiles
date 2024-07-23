#!/bin/bash

# Quick and dirty implementation of null movement on Wayland using ydotool.
# Replace /dev/input/event19 with your actual keyboard event number. For example, use evtest.
KEYBOARD_DEVICE="/dev/input/event19"

# Key codes from evtest
KEY_A=30
KEY_D=32
KEY_W=17
KEY_S=31

# Ensure ydotoold is running
if ! pgrep -x "ydotoold" > /dev/null; then
    sudo ydotoold &
    sleep 1  # Give it a sec to start
fi

# Verify ydotoold socket
if [ ! -S /run/user/1000/.ydotool_socket ]; then
    exit 1
fi

export YDOTOOL_SOCKET=/run/user/1000/.ydotool_socket

# Variables to track key states
declare -A keys_held=(
    [$KEY_A]=0
    [$KEY_D]=0
    [$KEY_W]=0
    [$KEY_S]=0
)

send_event() {
    local key=$1
    local action=$2
    sudo YDOTOOL_SOCKET=$YDOTOOL_SOCKET ydotool key "$key:$action"
}

handle_key_event() {
    local key=$1
    local conflict_key=$2
    local value=$3

    if [ "$value" -eq 1 ]; then
        if [ "${keys_held[$conflict_key]}" -eq 1 ]; then
            keys_held[$conflict_key]=0
            send_event "$conflict_key" "0"
        fi
        keys_held[$key]=1
        send_event "$key" "1"
    else
        keys_held[$key]=0
        send_event "$key" "0"
    fi
}

# Use stdbuf -oL for line buffering- less delay.
sudo stdbuf -oL evtest "$KEYBOARD_DEVICE" | while read -r event; do
    if echo "$event" | grep -q "code $KEY_A"; then
        value=$(echo "$event" | grep -o "value [01]" | awk '{print $2}')
        [ -n "$value" ] && handle_key_event $KEY_A $KEY_D $value
    elif echo "$event" | grep -q "code $KEY_D"; then
        value=$(echo "$event" | grep -o "value [01]" | awk '{print $2}')
        [ -n "$value" ] && handle_key_event $KEY_D $KEY_A $value
    elif echo "$event" | grep -q "code $KEY_W"; then
        value=$(echo "$event" | grep -o "value [01]" | awk '{print $2}')
        [ -n "$value" ] && handle_key_event $KEY_W $KEY_S $value
    elif echo "$event" | grep -q "code $KEY_S"; then
        value=$(echo "$event" | grep -o "value [01]" | awk '{print $2}')
        [ -n "$value" ] && handle_key_event $KEY_S $KEY_W $value
    fi
done
