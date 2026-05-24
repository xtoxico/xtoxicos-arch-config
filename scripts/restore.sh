#!/bin/bash

# Arch Linux Config Manager - Full Restore
# Autor: Gemini CLI
# Descripción: Restaura un perfil completo (Paquetes + Usuario).

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Obtener lista de perfiles
PROFILES=($(ls profiles/))

if [ ${#PROFILES[@]} -eq 0 ]; then
    echo -e "${RED}Error: No se encontraron perfiles en 'profiles/'. Ejecuta scripts/decrypt.sh primero.${NC}"
    exit 1
fi

echo -e "${BLUE}--- Restauración de Perfil Completo ---${NC}"
echo -e "Selecciona el perfil que quieres aplicar TOTALMENTE a este equipo."

select profile in "${PROFILES[@]}"; do
    if [ -n "$profile" ]; then
        echo -e "${RED}ADVERTENCIA: Esto sobrescribirá configuraciones locales.${NC}"
        read -p "¿Restaurar todo desde '$profile'? (s/n): " CONFIRM
        if [[ "$CONFIRM" =~ ^[Ss]$ ]]; then
            # 1. Usuario
            cp "profiles/$profile/user/zshrc" ~/.zshrc 2>/dev/null || true
            cp "profiles/$profile/user/nanorc" ~/.nanorc 2>/dev/null || true
            cp "profiles/$profile/user/gitconfig" ~/.gitconfig 2>/dev/null || true
            if [ -d "profiles/$profile/user/btop" ]; then
                mkdir -p ~/.config/btop
                cp "profiles/$profile/user/btop/btop.conf" ~/.config/btop/btop.conf 2>/dev/null || true
            fi
            # dconf
            if command -v dconf &> /dev/null; then
                [ -f "profiles/$profile/user/gnome_extensions.dconf" ] && dconf load /org/gnome/shell/extensions/ < "profiles/$profile/user/gnome_extensions.dconf"
                [ -f "profiles/$profile/user/gnome_interface.dconf" ] && dconf load /org/gnome/desktop/interface/ < "profiles/$profile/user/gnome_interface.dconf"
            fi
            
            # 2. Paquetes
            if [ -f "profiles/$profile/packages/pkglist.txt" ]; then
                sudo pacman -S --needed --noconfirm - < "profiles/$profile/packages/pkglist.txt"
            fi
            if [ -f "profiles/$profile/packages/aurlist.txt" ]; then
                if command -v yay &> /dev/null; then
                    yay -S --needed --noconfirm - < "profiles/$profile/packages/aurlist.txt"
                elif command -v paru &> /dev/null; then
                    paru -S --needed --noconfirm - < "profiles/$profile/packages/aurlist.txt"
                fi
            fi
            echo -e "${GREEN}Perfil '$profile' restaurado correctamente.${NC}"
        fi
        break
    fi
done
