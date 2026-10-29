#!/usr/bin/env bash
#
# auditoria_cv2.sh
#
# 1. Ejecuta extraer_orderar.sh para organizar los archivos del directorio
#    origen en subcarpetas (por tipo o extensión) dentro del directorio destino.
# 2. Audita los archivos .py resultantes buscando el uso de visión por
#    computadora (cv2 / import cv2 / opencv).
#
# Uso: ./auditoria_cv2.sh <directorio_origen> <directorio_destino>

set -uo pipefail

# --- Colores (solo si la salida es una terminal) ---------------------------
if [[ -t 1 ]]; then
    VERDE=$'\e[32m'; ROJO=$'\e[31m'; AMARILLO=$'\e[33m'; NEGRITA=$'\e[1m'; RESET=$'\e[0m'
else
    VERDE=""; ROJO=""; AMARILLO=""; NEGRITA=""; RESET=""
fi

# --- Validación de argumentos ----------------------------------------------
if [[ $# -ne 2 ]]; then
    echo "Uso: $0 <directorio_origen> <directorio_destino>" >&2
    exit 1
fi

ORIGEN="$1"
DESTINO="$2"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_ORDENAR="$SCRIPT_DIR/extraer_orderar.sh"

# Términos clave de visión por computadora (regex extendida, sin distinguir mayúsculas)
PATRON='\bcv2\b|opencv'

# --- Paso 1: organizar archivos --------------------------------------------
if [[ ! -f "$SCRIPT_ORDENAR" ]]; then
    echo "${ROJO}Error:${RESET} no se encontró $SCRIPT_ORDENAR" >&2
    exit 1
fi

echo "${NEGRITA}==> Organizando archivos con $(basename "$SCRIPT_ORDENAR")...${RESET}"
if ! bash "$SCRIPT_ORDENAR" "$ORIGEN" "$DESTINO"; then
    echo "${ROJO}Error:${RESET} $(basename "$SCRIPT_ORDENAR") terminó con errores" >&2
    exit 1
fi

if [[ ! -d "$DESTINO" ]]; then
    echo "${ROJO}Error:${RESET} el directorio destino '$DESTINO' no existe" >&2
    exit 1
fi

# --- Paso 2: auditoría de código Python ------------------------------------
# Se buscan los .py en cualquier subcarpeta del destino, así funciona tanto si
# el organizador los dejó en py/ como en codigo/.
echo
echo "${NEGRITA}==> Auditoría de código: buscando '$PATRON' en archivos .py${RESET}"
echo

total=0
con_cv2=0

while IFS= read -r -d '' archivo; do
    (( total++ ))
    echo "${NEGRITA}Archivo:${RESET} $archivo"

    coincidencias="$(grep -nEi "$PATRON" "$archivo")"
    if [[ -n "$coincidencias" ]]; then
        (( con_cv2++ ))
        echo "  Contiene cv2: ${VERDE}SÍ${RESET}"
        while IFS= read -r linea; do
            echo "    Línea ${linea%%:*}: ${linea#*:}"
        done <<< "$coincidencias"
    else
        echo "  Contiene cv2: ${ROJO}NO${RESET}"
    fi
    echo
done < <(find "$DESTINO" -type f -name '*.py' -print0 | sort -z)

# --- Resumen final ---------------------------------------------------------
echo "${NEGRITA}==================== RESUMEN ====================${RESET}"
if (( total == 0 )); then
    echo "${AMARILLO}No se encontraron archivos .py en '$DESTINO'.${RESET}"
else
    echo "Archivos .py analizados:  $total"
    echo "Archivos que usan cv2:    $con_cv2"
    echo "Archivos sin cv2:         $(( total - con_cv2 ))"
fi
echo "${NEGRITA}=================================================${RESET}"
