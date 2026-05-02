#!/bin/bash

# xtoxico's Arch Linux Setup Script
# Autor: xtoxico
# Descripción: Replica la configuración de Arch Linux, instala paquetes, NVM, Zsh y GNOME.

set -e

# Colores para la salida
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}--- Iniciando la restauración del sistema ---${NC}"

# 1. Actualización inicial
echo -e "${GREEN}[1/8] Actualizando sistema...${NC}"
sudo pacman -Syu --noconfirm

# 2. Instalación de YAY (AUR Helper)
if ! command -v yay &> /dev/null; then
    echo -e "${GREEN}[2/8] Instalando yay...${NC}"
    sudo pacman -S --needed base-devel git --noconfirm
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd -
else
    echo -e "${GREEN}[2/8] Yay ya está instalado.${NC}"
fi

# 3. Instalación de paquetes de Pacman
if [ -f "pkglist.txt" ]; then
    echo -e "${GREEN}[3/8] Instalando paquetes de pacman...${NC}"
    sudo pacman -S --needed --noconfirm - < pkglist.txt
fi

# 4. Instalación de paquetes de AUR
if [ -f "aurlist.txt" ]; then
    echo -e "${GREEN}[4/8] Instalando paquetes de AUR...${NC}"
    yay -S --needed --noconfirm - < aurlist.txt
fi

# 5. Instalación de NVM y Node.js 22
if [ ! -d "$HOME/.nvm" ]; then
    echo -e "${GREEN}[5/8] Instalando NVM...${NC}"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    echo -e "${GREEN}Instalando Node.js v22...${NC}"
    nvm install 22
    nvm use 22
    nvm alias default 22
else
    echo -e "${GREEN}[5/8] NVM ya está instalado.${NC}"
fi

# 6. Configuración de Zsh y Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo -e "${GREEN}[6/8] Instalando Oh My Zsh...${NC}"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    
    # Plugins personalizados
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi

echo -e "${GREEN}Copiando archivos de configuración...${NC}"
cp configs/zshrc ~/.zshrc
cp configs/nanorc ~/.nanorc

# 7. Configuración de GNOME
echo -e "${GREEN}[7/8] Aplicando configuración de GNOME...${NC}"
if [ -f "configs/gnome_extensions.dconf" ]; then
    dconf load /org/gnome/shell/extensions/ < configs/gnome_extensions.dconf
fi
if [ -f "configs/gnome_interface.dconf" ]; then
    dconf load /org/gnome/desktop/interface/ < configs/gnome_interface.dconf
fi

# 8. Finalización
echo -e "${BLUE}--- Configuración completada con éxito ---${NC}"
echo -e "Por favor, reinicia tu terminal o ejecuta 'source ~/.zshrc'"
