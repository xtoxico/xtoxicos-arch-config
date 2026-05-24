#!/bin/bash

# Arch Linux Config Manager - Partial Restore (Mix & Match)
# Autor: Gemini CLI
# Descripción: Permite elegir partes de diferentes perfiles para restaurar.

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Función para mostrar la bitácora si existe
show_bitacora() {
    local profile=$1
    if [ -f "profiles/$profile/bitacora.md" ]; then
        echo -e "${BLUE}--- Bitácora de la IA para el perfil '$profile' ---${NC}"
        cat "profiles/$profile/bitacora.md"
        echo -e "${BLUE}---------------------------------------------------${NC}"
    else
        echo -e "${YELLOW}No hay bitácora disponible para el perfil '$profile'.${NC}"
    fi
}

# Función para backup de seguridad
safe_copy() {
    local src=$1
    local dest=$2
    if [ -f "$dest" ]; then
        echo -e "Creando backup: $dest.bak"
        sudo cp "$dest" "$dest.bak"
    fi
    sudo cp "$src" "$dest"
}

# Obtener lista de perfiles
PROFILES=($(ls profiles/))

if [ ${#PROFILES[@]} -eq 0 ]; then
    echo -e "${RED}Error: No se encontraron perfiles en 'profiles/'. Ejecuta scripts/decrypt.sh primero.${NC}"
    exit 1
fi

echo -e "${BLUE}--- Restauración Parcial Interactiva ---${NC}"
echo -e "Selecciona de qué perfil quieres obtener cada categoría."

# --- CATEGORÍA 1: TERMINAL Y USUARIO ---
echo -e "\n${GREEN}[1/3] CONFIGURACIÓN DE USUARIO (Zsh, Nano, Git, GNOME)${NC}"
select profile in "${PROFILES[@]}" "Saltar"; do
    if [ "$profile" == "Saltar" ]; then break; fi
    if [ -n "$profile" ]; then
        show_bitacora "$profile"
        read -p "¿Restaurar archivos de usuario desde '$profile'? (s/n): " CONFIRM
        if [[ "$CONFIRM" =~ ^[Ss]$ ]]; then
            cp "profiles/$profile/user/zshrc" ~/.zshrc 2>/dev/null || true
            cp "profiles/$profile/user/nanorc" ~/.nanorc 2>/dev/null || true
            cp "profiles/$profile/user/gitconfig" ~/.gitconfig 2>/dev/null || true
            if [ -d "profiles/$profile/user/btop" ]; then
                mkdir -p ~/.config/btop
                cp "profiles/$profile/user/btop/btop.conf" ~/.config/btop/btop.conf 2>/dev/null || true
            fi
            # dconf GNOME
            if command -v dconf &> /dev/null; then
                [ -f "profiles/$profile/user/gnome_extensions.dconf" ] && dconf load /org/gnome/shell/extensions/ < "profiles/$profile/user/gnome_extensions.dconf"
                [ -f "profiles/$profile/user/gnome_interface.dconf" ] && dconf load /org/gnome/desktop/interface/ < "profiles/$profile/user/gnome_interface.dconf"
            fi
            echo -e "${GREEN}Archivos de usuario restaurados.${NC}"
        fi
        break
    fi
done

# --- CATEGORÍA 2: PAQUETES ---
echo -e "\n${GREEN}[2/3] INSTALACIÓN DE PAQUETES${NC}"
select profile in "${PROFILES[@]}" "Saltar"; do
    if [ "$profile" == "Saltar" ]; then break; fi
    if [ -n "$profile" ]; then
        echo -e "Perfil seleccionado: $profile"
        read -p "¿Instalar paquetes de pacman y AUR desde '$profile'? (s/n): " CONFIRM
        if [[ "$CONFIRM" =~ ^[Ss]$ ]]; then
            # Pacman
            if [ -f "profiles/$profile/packages/pkglist.txt" ]; then
                sudo pacman -S --needed --noconfirm - < "profiles/$profile/packages/pkglist.txt"
            fi
            # AUR
            if [ -f "profiles/$profile/packages/aurlist.txt" ]; then
                if command -v yay &> /dev/null; then
                    yay -S --needed --noconfirm - < "profiles/$profile/packages/aurlist.txt"
                elif command -v paru &> /dev/null; then
                    paru -S --needed --noconfirm - < "profiles/$profile/packages/aurlist.txt"
                fi
            fi
        fi
        break
    fi
done

# --- CATEGORÍA 3: SISTEMA (/etc) ---
echo -e "\n${RED}[3/3] CONFIGURACIÓN DE SISTEMA (PELIGRO: fstab, PAM, etc.)${NC}"
select profile in "${PROFILES[@]}" "Saltar"; do
    if [ "$profile" == "Saltar" ]; then break; fi
    if [ -n "$profile" ]; then
        show_bitacora "$profile"
        echo -e "${YELLOW}ADVERTENCIA: Sobrescribir archivos de /etc puede impedir que el sistema arranque.${NC}"
        read -p "¿Estás SEGURO de querer restaurar archivos de sistema de '$profile'? (escribe 'SI' para confirmar): " CONFIRM
        if [ "$CONFIRM" == "SI" ]; then
            # fstab
            [ -f "profiles/$profile/system/fstab" ] && safe_copy "profiles/$profile/system/fstab" "/etc/fstab"
            # mkinitcpio
            [ -f "profiles/$profile/system/mkinitcpio.conf" ] && safe_copy "profiles/$profile/system/mkinitcpio.conf" "/etc/mkinitcpio.conf"
            # PAM
            if [ -d "profiles/$profile/system/pam.d" ]; then
                echo "Restaurando /etc/pam.d/..."
                sudo cp -r profiles/$profile/system/pam.d/* /etc/pam.d/
            fi
            echo -e "${GREEN}Archivos de sistema restaurados. Se recomienda reiniciar.${NC}"
        fi
        break
    fi
done

echo -e "\n${BLUE}--- Proceso de restauración finalizado ---${NC}"
