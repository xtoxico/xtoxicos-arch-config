#!/bin/bash

# Arch Linux Config Manager - Launcher
# Autor: Gemini CLI

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}--- Arch Linux Config Manager ---${NC}"
echo "Selecciona una opción:"
echo "1) Realizar Backup (Guardar configuración actual)"
echo "2) Generar Bitácora con IA (Requiere Gemini API Key)"
echo "3) Restaurar Perfil Completo"
echo "4) Restaurar Parcial (Mix & Match)"
echo "5) Cifrar perfiles para GitHub (.github_vault.zip)"
echo "6) Descifrar perfiles (.github_vault.zip)"
echo "7) Salir"

read -p "Opción: " OPT

case $OPT in
    1) ./scripts/backup.sh ;;
    2) ./scripts/backup_ia.sh ;;
    3) ./scripts/restore.sh ;;
    4) ./scripts/restore_partial.sh ;;
    5) ./scripts/encrypt.sh ;;
    6) ./scripts/decrypt.sh ;;
    7) exit 0 ;;
    *) echo -e "${YELLOW}Opción no válida.${NC}" ;;
esac
