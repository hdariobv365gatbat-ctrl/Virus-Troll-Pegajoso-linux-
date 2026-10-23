#!/bin/bash

SCRIPT_PATH="$(realpath "$0")"
AUTOSTART_DIR="$HOME/.config/autostart"
DESKTOP_FILE="$AUTOSTART_DIR/zy.desktop"

if [ ! -f "$DESKTOP_FILE" ]; then
    mkdir -p "$AUTOSTART_DIR"
    echo "[Desktop Entry]" > "$DESKTOP_FILE"
    echo "Type=Application" >> "$DESKTOP_FILE"
    echo "Exec=bash \"$SCRIPT_PATH\"" >> "$DESKTOP_FILE"
    echo "Hidden=false" >> "$DESKTOP_FILE"
    echo "NoDisplay=true" >> "$DESKTOP_FILE"
    echo "X-GNOME-Autostart-enabled=true" >> "$DESKTOP_FILE"
    echo "Name=Tonoto" >> "$DESKTOP_FILE"
    echo "Comment=Cambiador automatico de fondo" >> "$DESKTOP_FILE"
fi

while true; do
    imagen=$(find "$HOME" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \) 2>/dev/null | shuf -n 1)
    
    if [ -n "$imagen" ]; then
        gsettings set org.gnome.desktop.background picture-uri "file://$imagen"
        gsettings set org.gnome.desktop.background picture-uri-dark "file://$imagen"
    fi

    sleep 2
done