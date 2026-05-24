#!/bin/bash

# Arch Linux Config Manager - AI Bitácora Generator
# Autor: Gemini CLI
# Descripción: Usa la API de Gemini para documentar las configuraciones.

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# 1. Obtener API KEY
if [ -f ".env" ]; then
    source .env
fi

if [ -z "$GEMINI_API_KEY" ]; then
    echo -e "${YELLOW}No se detectó GEMINI_API_KEY en .env${NC}"
    read -p "Introduce tu Gemini API Key: " GEMINI_API_KEY
    echo "GEMINI_API_KEY=$GEMINI_API_KEY" >> .env
    chmod 600 .env
fi

# 2. Selección de Perfil
echo -e "${BLUE}--- Generador de Bitácora con IA ---${NC}"
read -p "Nombre del perfil a documentar: " PROFILE_NAME

if [ ! -d "profiles/$PROFILE_NAME" ]; then
    echo -e "${RED}Error: El perfil '$PROFILE_NAME' no existe localmente.${NC}"
    exit 1
fi

PROFILE_DIR="profiles/$PROFILE_NAME"
BITACORA_FILE="$PROFILE_DIR/bitacora.md"

# 3. Recolectar contexto para la IA
echo -e "${GREEN}Analizando archivos para enviar a Gemini...${NC}"

CONTEXT="Eres un experto en Arch Linux. Voy a pasarte varios archivos de configuración de un equipo llamado '$PROFILE_NAME'. 
Tu tarea es generar una 'Bitácora' en Markdown que explique de forma concisa:
1. Qué tipo de equipo es (según los paquetes).
2. Qué personalizaciones visuales tiene (Zsh, GNOME).
3. Qué configuraciones críticas de sistema tiene (/etc).
4. Un resumen para que el usuario decida si quiere restaurar estas partes.

Archivos adjuntos:
"

# Añadir resúmenes de archivos al contexto (limitado para no exceder tokens)
if [ -f "$PROFILE_DIR/packages/pkglist.txt" ]; then
    CONTEXT+="\n--- Paquetes Pacman (Top 20) ---\n$(head -n 20 $PROFILE_DIR/packages/pkglist.txt)\n"
fi

if [ -f "$PROFILE_DIR/user/zshrc" ]; then
    CONTEXT+="\n--- Fragmento de .zshrc ---\n$(grep -v '^#' $PROFILE_DIR/user/zshrc | head -n 30)\n"
fi

if [ -f "$PROFILE_DIR/system/fstab" ]; then
    CONTEXT+="\n--- Archivo fstab ---\n$(cat $PROFILE_DIR/system/fstab)\n"
fi

# 4. Llamada a la API de Gemini
echo -e "${BLUE}Consultando a Gemini...${NC}"

PAYLOAD=$(cat <<EOF
{
  "contents": [{
    "parts":[{
      "text": "$CONTEXT"
    }]
  }]
}
EOF
)

RESPONSE=$(curl -s -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$GEMINI_API_KEY" \
    -H 'Content-Type: application/json' \
    -d "$PAYLOAD")

# Extraer el texto de la respuesta (usando sed/grep simple para evitar dependencias de jq si no está)
RESULT=$(echo "$RESPONSE" | grep -oP '"text":\s*"\K[^"]+' | sed 's/\\n/\n/g' | sed 's/\\"/"/g')

if [ -z "$RESULT" ]; then
    echo -e "${RED}Error: No se pudo obtener respuesta de la IA. Revisa tu API Key o conexión.${NC}"
    echo "Respuesta cruda: $RESPONSE"
    exit 1
fi

# 5. Guardar Bitácora
echo -e "# Bitácora de Configuración - Perfil: $PROFILE_NAME\n" > "$BITACORA_FILE"
echo -e "Generado el: $(date)\n" >> "$BITACORA_FILE"
echo -e "$RESULT" >> "$BITACORA_FILE"

echo -e "${GREEN}Bitácora generada con éxito en $BITACORA_FILE${NC}"
