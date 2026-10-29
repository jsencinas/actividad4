#!/usr/bin/env bash
# Uso: ./extraer_ordenar.sh <archivo.zip> <directorio_destino>
# Extrae el zip y organiza los archivos en carpetas según su extensión.
set -euo pipefail

if [ $# -ne 2 ]; then
  echo "Uso: $0 <archivo.zip> <directorio_destino>" >&2
  exit 1
fi

zip="$1"
destino="$2"

[ -f "$zip" ] || { echo "Error: no existe el archivo '$zip'" >&2; exit 1; }
unzip -tq "$zip" >/dev/null || { echo "Error: '$zip' no es un zip válido" >&2; exit 1; }

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

unzip -q "$zip" -d "$tmp"
mkdir -p "$destino"

categoria() {
  case "$1" in
    py|js|ts|sh|c|cpp|h|java|html|css|sql|rb|go) echo codigo ;;
    png|jpg|jpeg|gif|webp|svg|bmp|ico|tiff)      echo imagenes ;;
    pdf|doc|docx|txt|md|ppt|pptx|odt|rtf)        echo documentos ;;
    csv|xls|xlsx|json|xml|tsv)                   echo datos ;;
    mp3|wav|ogg|flac|m4a|aac)                    echo audio ;;
    *)                                           echo otros ;;
  esac
}

total=0
# Ignora metadatos de macOS (__MACOSX/, .DS_Store, ._*)
while IFS= read -r -d '' f; do
  nombre="$(basename "$f")"
  if [[ "$nombre" == *.* ]]; then
    ext="$(echo "${nombre##*.}" | tr '[:upper:]' '[:lower:]')"
  else
    ext=""
  fi
  carpeta="$destino/$(categoria "$ext")"
  mkdir -p "$carpeta"

  # Si ya existe un archivo con ese nombre, agrega sufijo _1, _2, ...
  final="$carpeta/$nombre"
  n=1
  while [ -e "$final" ]; do
    if [ -n "$ext" ]; then
      final="$carpeta/${nombre%.*}_$n.${nombre##*.}"
    else
      final="$carpeta/${nombre}_$n"
    fi
    n=$((n + 1))
  done

  mv "$f" "$final"
  total=$((total + 1))
done < <(find "$tmp" -type f ! -path '*/__MACOSX/*' ! -name '.DS_Store' ! -name '._*' -print0)

echo "Listo: $total archivos organizados en '$destino'"
for d in "$destino"/*/; do
  [ -d "$d" ] && printf '  %-12s %s\n' "$(basename "$d")/" "$(find "$d" -type f | wc -l | tr -d ' ')"
done
