#!/bin/bash

# Define the list of applications as key-value pairs
declare -A apps=(
    ["Spotify"]="spotify"
    ["Steam"]="steam"
    ["Modrinth"]="modrinth-app"
    ["Firefox"]="firefox"
    ["VS Code"]="code"
    ["Terminal"]="kitty"
    ["File Manager"]="thunar"
    ["Burp Suite"]="java -jar -Xmx6g /home/tommy/BurpSuitePro/burpsuite_pro.jar"
    ["Virtual Machines"]="virt-manager"
    ["Monero GUI"]="monero-wallet-gui"
    ["Ledger GUI"]="ledger-live-desktop"
)

# Construct the list of application names for wofi
app_list=$(printf "%s\n" "${!apps[@]}")

# Prompt user to select an application
selected_app=$(echo -e "$app_list" | wofi --dmenu --prompt "Select Application:")

# Debug: log the selected application
echo "Selected application: '$selected_app'"

# If an application is selected, execute it
if [ -n "$selected_app" ]; then
    # Get the corresponding command
    app_command=${apps["$selected_app"]}
    if [ -n "$app_command" ]; then
        # Execute the selected application
        echo "Executing: $app_command"
        eval "$app_command" &
    else
        echo "Error: No command found for '$selected_app'."
    fi
else
    echo "No application selected."
fi
