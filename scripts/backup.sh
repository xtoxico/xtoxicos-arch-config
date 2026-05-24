#!/bin/bash

# Arch Linux Config Manager - Advanced Backup Engine
# Autor: Gemini CLI
# Descripción: Respalda configuraciones de usuario y sistema en perfiles locales.

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 1. Selección de Perfil
HOSTNAME=$(uname -n)
DEFAULT_PROFILE="desktop"
[ "$HOSTNAME" == "thinkpad" ] && DEFAULT_PROFILE="thinkpad"

echo -e "${BLUE}--- Motor de Backup de Arch Linux ---${NC}"
read -p "Nombre del perfil a respaldar [Default: $DEFAULT_PROFILE]: " PROFILE_NAME
PROFILE_NAME=${PROFILE_NAME:-$DEFAULT_PROFILE}

PROFILE_DIR="profiles/$PROFILE_NAME"
mkdir -p "$PROFILE_DIR/packages" "$PROFILE_DIR/user" "$PROFILE_DIR/system"

echo -e "${GREEN}Respaldando en perfil: $PROFILE_NAME${NC}"

# 2. Respaldar Paquetes
echo -e "${BLUE}[1/4] Respaldando lista de paquetes...${NC}"
pacman -Qqen > "$PROFILE_DIR/packages/pkglist.txt"
if command -v yay &> /dev/null; then
    yay -Qqem > "$PROFILE_DIR/packages/aurlist.txt"
elif command -v paru &> /dev/null; then
    paru -Qqem > "$PROFILE_DIR/packages/aurlist.txt"
fi

# 3. Respaldar Configuraciones de Usuario
echo -e "${BLUE}[2/4] Respaldando configuraciones de usuario...${NC}"
[ -f ~/.zshrc ] && cp ~/.zshrc "$PROFILE_DIR/user/zshrc"
[ -f ~/.nanorc ] && cp ~/.nanorc "$PROFILE_DIR/user/nanorc"
[ -f ~/.gitconfig ] && cp ~/.gitconfig "$PROFILE_DIR/user/gitconfig"

# Btop
if [ -d ~/.config/btop ]; then
    mkdir -p "$PROFILE_DIR/user/btop"
    cp ~/.config/btop/btop.conf "$PROFILE_DIR/user/btop/btop.conf" 2>/dev/null || true
fi

# GNOME (dconf)
if command -v dconf &> /dev/null; then
    echo -e "Exportando configuración de GNOME..."
    dconf dump /org/gnome/shell/extensions/ > "$PROFILE_DIR/user/gnome_extensions.dconf"
    dconf dump /org/gnome/desktop/interface/ > "$PROFILE_DIR/user/gnome_interface.dconf"
fi

# 4. Respaldar Configuraciones del Sistema (/etc)
echo -e "${BLUE}[3/4] Respaldando archivos de sistema (/etc)...${NC}"
FILES_TO_BACKUP=(
    "/etc/fstab"
    "/etc/mkinitcpio.conf"
    "/etc/pacman.conf"
    "/etc/hostname"
    "/etc/hosts"
)

for file in "${FILES_TO_BACKUP[@]}"; do
    if [ -f "$file" ]; then
        echo "Copiando $file..."
        cp "$file" "$PROFILE_DIR/system/"
    fi
done

# Directorios específicos (PAM)
if [ -d "/etc/pam.d" ]; then
    echo "Copiando /etc/pam.d/..."
    mkdir -p "$PROFILE_DIR/system/pam.d"
    sudo cp -r /etc/pam.d/* "$PROFILE_DIR/system/pam.d/"
    sudo chown -R $USER:$USER "$PROFILE_DIR/system/pam.d/"
fi

# 5. Cifrado y Git Push (Opcional)
echo -e "${BLUE}[4/4] Finalizando...${NC}"
read -p "¿Deseas cifrar y subir los cambios a GitHub ahora? (s/n): " PUSH_NOW

if [[ "$PUSH_NOW" =~ ^[Ss]$ ]]; then
    ./scripts/encrypt.sh
    
    echo -e "${YELLOW}Preparando Git Push...${NC}"
    git add .github_vault.zip .gitignore scripts/ README.md
    read -p "Mensaje del commit: " COMMIT_MSG
    COMMIT_MSG=${COMMIT_MSG:-"Update backup: $PROFILE_NAME $(date +%F)"}
    
    git commit -m "$COMMIT_MSG"
    git push
    echo -e "${GREEN}¡Todo subido con éxito!${NC}"
else
    echo -e "${YELLOW}Backup completado localmente en $PROFILE_DIR.${NC}"
    echo -e "No olvides ejecutar ./scripts/encrypt.sh antes de subir a Git."
fi
