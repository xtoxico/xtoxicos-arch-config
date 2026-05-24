#!/bin/bash

# Arch Linux Config Manager - Encrypt Script
# Comprime la carpeta profiles/ en .github_vault.zip con contraseña.

YELLOW='\033[1;33m'
NC='\033[0m'

if [ ! -d "profiles" ]; then
    echo -e "${YELLOW}Error: La carpeta 'profiles/' no existe.${NC}"
    exit 1
fi

echo -e "${YELLOW}Cifrando perfiles en .github_vault.zip...${NC}"
echo -e "Se te pedirá una contraseña. NO LA OLVIDES."

# Eliminar el anterior si existe
rm -f .github_vault.zip

# Comprimir con cifrado
zip -er .github_vault.zip profiles/

if [ $? -eq 0 ]; then
    echo -e "${YELLOW}Archivo .github_vault.zip creado con éxito.${NC}"
else
    echo -e "${YELLOW}Error al cifrar el archivo.${NC}"
    exit 1
fi
