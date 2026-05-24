#!/bin/bash

# Arch Linux Config Manager - Decrypt Script
# Descifra .github_vault.zip en la carpeta profiles/.

YELLOW='\033[1;33m'
NC='\033[0m'

if [ ! -f ".github_vault.zip" ]; then
    echo -e "${YELLOW}Error: No se encontró el archivo .github_vault.zip.${NC}"
    exit 1
fi

echo -e "${YELLOW}Descifrando .github_vault.zip...${NC}"
echo -e "Introduce la contraseña para extraer los perfiles."

unzip .github_vault.zip

if [ $? -eq 0 ]; then
    echo -e "${YELLOW}Perfiles extraídos correctamente en 'profiles/'.${NC}"
else
    echo -e "${YELLOW}Error al descifrar el archivo. Asegúrate de que la contraseña sea correcta.${NC}"
    exit 1
fi
