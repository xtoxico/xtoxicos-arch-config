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

# 1. Obtener API KEY y MODELO
if [ -f ".env" ]; then
    source .env
fi

if [ -z "$GEMINI_API_KEY" ]; then
    echo -e "${YELLOW}No se detectó GEMINI_API_KEY en .env${NC}"
    read -p "Introduce tu Gemini API Key: " GEMINI_API_KEY
    echo "GEMINI_API_KEY=$GEMINI_API_KEY" >> .env
    chmod 600 .env
fi

# Configurar modelo por defecto si no existe
if [ -z "$GEMINI_MODEL" ]; then
    GEMINI_MODEL="gemini-2.0-flash"
fi

# 2. Selección de Perfil
echo -e "${BLUE}--- Generador de Bitácora con IA (Modelo: $GEMINI_MODEL) ---${NC}"
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
    CONTEXT="$CONTEXT
--- Paquetes Pacman (Top 20) ---
$(head -n 20 "$PROFILE_DIR/packages/pkglist.txt")
"
fi

if [ -f "$PROFILE_DIR/user/zshrc" ]; then
    CONTEXT="$CONTEXT
--- Fragmento de .zshrc ---
$(grep -v '^#' "$PROFILE_DIR/user/zshrc" | head -n 30)
"
fi

if [ -f "$PROFILE_DIR/system/fstab" ]; then
    CONTEXT="$CONTEXT
--- Archivo fstab ---
$(cat "$PROFILE_DIR/system/fstab")
"
fi

# 4. Llamada a la API de Gemini
echo -e "${BLUE}Consultando a Gemini ($GEMINI_MODEL)...${NC}"

# Generar JSON de forma segura con Python
PAYLOAD=$(printf '%s' "$CONTEXT" | python3 -c 'import json, sys; print(json.dumps({"contents": [{"parts": [{"text": sys.stdin.read()}]}]}))')

RESPONSE=$(curl -s -X POST "https://generativelanguage.googleapis.com/v1/models/$GEMINI_MODEL:generateContent?key=$GEMINI_API_KEY" \
    -H 'Content-Type: application/json' \
    -d "$PAYLOAD")

# Extraer el texto de la respuesta de forma segura con Python
RESULT=$(echo "$RESPONSE" | python3 -c '
import json, sys
try:
    data = json.load(sys.stdin)
    if "candidates" in data:
        print(data["candidates"][0]["content"]["parts"][0]["text"])
except Exception:
    pass
')

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
