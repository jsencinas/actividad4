#!/usr/bin/env bash
#
# auditoria_pyside6.sh
#
# 1. Ejecuta extraer_ordenar.sh para extraer el zip y organizar sus archivos
#    en subcarpetas por tipo (codigo/, imagenes/, ...) dentro del directorio destino.
# 2. Audita los archivos .py resultantes buscando el uso de la librería
#    de interfaces gráficas PySide6 (import PySide6 / from PySide6 ...).
#
# Uso: ./auditoria_pyside6.sh <archivo.zip> <directorio_destino>

set -uo pipefail

# --- Colores (solo si la salida es una terminal) ---------------------------
if [[ -t 1 ]]; then
    VERDE=$'\e[32m'; ROJO=$'\e[31m'; AMARILLO=$'\e[33m'; NEGRITA=$'\e[1m'; RESET=$'\e[0m'
else
    VERDE=""; ROJO=""; AMARILLO=""; NEGRITA=""; RESET=""
fi

# --- Validación de argumentos ----------------------------------------------
if [[ $# -ne 2 ]]; then
    echo "Uso: $0 <archivo.zip> <directorio_destino>" >&2
    exit 1
fi

ZIP="$1"
DESTINO="$2"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_ORDENAR="$SCRIPT_DIR/extraer_ordenar.sh"

# Librería buscada (regex extendida, sin distinguir mayúsculas)
PATRON='\bPySide6\b'

# --- Paso 1: organizar archivos --------------------------------------------
if [[ ! -f "$SCRIPT_ORDENAR" ]]; then
    echo "${ROJO}Error:${RESET} no se encontró $SCRIPT_ORDENAR" >&2
    exit 1
fi

echo "${NEGRITA}==> Organizando archivos con $(basename "$SCRIPT_ORDENAR")...${RESET}"
if ! bash "$SCRIPT_ORDENAR" "$ZIP" "$DESTINO"; then
    echo "${ROJO}Error:${RESET} $(basename "$SCRIPT_ORDENAR") terminó con errores" >&2
    exit 1
fi

if [[ ! -d "$DESTINO" ]]; then
    echo "${ROJO}Error:${RESET} el directorio destino '$DESTINO' no existe" >&2
    exit 1
fi

# --- Paso 2: auditoría de código Python ------------------------------------
# Se buscan los .py en cualquier subcarpeta del destino, así funciona tanto si
# el organizador los dejó en codigo/ como en py/.
echo
echo "${NEGRITA}==> Auditoría de código: buscando '$PATRON' en archivos .py${RESET}"
echo

total=0
con_pyside6=0

while IFS= read -r -d '' archivo; do
    (( total++ ))
    echo "${NEGRITA}Archivo:${RESET} $archivo"

    coincidencias="$(grep -nEi "$PATRON" "$archivo")"
    if [[ -n "$coincidencias" ]]; then
        (( con_pyside6++ ))
        echo "  Contiene PySide6: ${VERDE}SÍ${RESET}"
        while IFS= read -r linea; do
            echo "    Línea ${linea%%:*}: ${linea#*:}"
        done <<< "$coincidencias"
    else
        echo "  Contiene PySide6: ${ROJO}NO${RESET}"
    fi
    echo
done < <(find "$DESTINO" -type f -iname '*.py' -print0 | sort -z)

# --- Resumen final ---------------------------------------------------------
echo "${NEGRITA}==================== RESUMEN ====================${RESET}"
if (( total == 0 )); then
    echo "${AMARILLO}No se encontraron archivos .py en '$DESTINO'.${RESET}"
else
    echo "Archivos .py analizados:   $total"
    echo "Archivos que usan PySide6: $con_pyside6"
    echo "Archivos sin PySide6:      $(( total - con_pyside6 ))"
fi
echo "${NEGRITA}=================================================${RESET}"
