#!/bin/bash

LCD_DEVICE="Kraken"

# Define the workstations
declare -A ws=(
    ["Modrinth"]="hyprctl dispatch exec [workspace 2 silent] 'firefox --new-window https://discord.com/channels/@me'; \
        hyprctl dispatch exec [workspace 2 silent] spotify; \
        hyprctl dispatch exec [workspace 1] modrinth-app"
    ["Work"]="hyprctl dispatch exec [workspace 2 silent] virt-manager; \
        hyprctl dispatch exec [workspace 1] 'firefox https://teams.microsoft.com/_ https://outlook.office365.com/';"
)

# Define the LCD images for each workstation (if LCD_DEVICE is set)
declare -A lcdImage=(
    ["Modrinth"]="/home/tommy/Documents/gifs/modrinth.gif"
    ["Work"]="/home/tommy/Documents/gifs/work.gif"
)

# Define the order of workstation names
workstation_order=(
    "Minecraft"
    "Work"
)

# Construct the list of workstation names for wofi in the specified order
ws_list=""
for ws_name in "${workstation_order[@]}"; do
    ws_list+="$ws_name\n"
done

# Prompt user to select a workstation
selected_ws=$(echo -e "$ws_list" | wofi -dmenu -p "Select Workstation:")

# If a workstation is selected, execute its commands
if [ -n "$selected_ws" ]; then
    # If LCD is enabled, set the image
    if [ -n "$LCD_DEVICE" ]; then
        liquidctl --match $LCD_DEVICE set lcd screen gif ${lcdImage["$selected_ws"]}
        echo ${lcdImage["$selected_ws"]}
    fi
    # Get the corresponding commands
    ws_commands=${ws["$selected_ws"]}
    if [ -n "$ws_commands" ]; then
        # Split the commands by semicolon and execute them one by one
        IFS=';' read -ra commands <<< "$ws_commands"
        for cmd in "${commands[@]}"; do
            hyprctl dispatch workspace 1
            eval "$cmd" &
        done
    else
        echo "Error: No commands found for '$selected_ws'."
    fi
fi
