#!/usr/bin/env bash
# Script de instalación para Modern Clock (Noctalia Plugin)
set -e

PLUGIN_NAME="modern_clock"
PLUGIN_DIR="$HOME/.config/noctalia/plugins/$PLUGIN_NAME"
PLUGINS_JSON="$HOME/.config/noctalia/plugins.json"

echo "[*] Iniciando la instalación de Modern Clock para Noctalia..."

# 1. Verificar e instalar dependencias nativas de Arch Linux
DEPS=("jq" "qt6-declarative")
for dep in "${DEPS[@]}"; do
    if ! pacman -Qs "^${dep}$" > /dev/null; then
        echo "[*] La dependencia '$dep' no está instalada."
        echo "[*] Solicitando permisos para instalar '$dep' vía pacman..."
        sudo pacman -S --noconfirm "$dep"
    else
        echo "[+] Dependencia '$dep' verificada."
    fi
done

# 2. Copiar los archivos del plugin al directorio de configuración
echo "[*] Copiando archivos a $PLUGIN_DIR..."
mkdir -p "$PLUGIN_DIR"
cp -r ./* "$PLUGIN_DIR/"

# 3. Habilitar el plugin en la configuración de Noctalia
if [ -f "$PLUGINS_JSON" ]; then
    echo "[*] Habilitando el plugin en plugins.json..."
    # Se utiliza un archivo temporal para evitar truncamientos
    jq '.states += {"modern_clock": {"enabled": true, "sourceUrl": "local"}}' "$PLUGINS_JSON" > /tmp/plugins_tmp.json && mv /tmp/plugins_tmp.json "$PLUGINS_JSON"
    echo "[+] Plugin registrado en Noctalia."
else
    echo "[!] Advertencia: No se encontró $PLUGINS_JSON."
    echo "[!] Deberás habilitar el plugin manualmente en los ajustes de la interfaz de Noctalia."
fi

# 4. Reiniciar la shell
echo "[*] Reiniciando la sesión de Quickshell/Noctalia..."
killall quickshell || true
sleep 1
quickshell -c ~/.config/noctalia/shell.qml & disown

echo "======================================================"
echo "[+] ¡Instalación completada con éxito!"
echo "[+] Abre la configuración de Noctalia y añade el widget"
echo "    Modern Clock a tu escritorio de Niri."
echo "======================================================"