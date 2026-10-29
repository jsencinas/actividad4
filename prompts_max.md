# Prompts de Max

## 1. Registro de prompts
**Prompt:** A partir de ahora guarda todos los prompts que te pida y un resumen de la respuesta en un md que se llame prompts_max.md

**Resumen de la respuesta:** Se creó `prompts_max.md` y se guardó en memoria la regla de registrar cada prompt con un resumen de la respuesta.

## 2. Script extraer_ordenar.sh
**Prompt:** Primero que nada analiza @proyecto_analisis.zip y a partir de esto genera un script extraer_ordenar.sh. Este debe de recibir 2 argumentos: ruta del archivo zip y la ruta del directorio donde se va a organizar la informacion. Nota: las carpetas se deben organizar por tipo de archivo/extension de archivo. ejemplo: documentos/, imagenes/, codigo/, otros/

**Resumen de la respuesta:** Se analizó el zip (98 archivos: .py, imágenes, pdf, csv, audio, .ttf, uno sin extensión, más basura de macOS). Se creó `extraer_ordenar.sh`: valida argumentos y zip, extrae a un directorio temporal, ignora `__MACOSX/`, `.DS_Store` y `._*`, y mueve cada archivo a codigo/, imagenes/, documentos/, datos/, audio/ u otros/ según su extensión; evita sobrescribir con sufijos `_1`, `_2`. Probado: 60 código, 26 imágenes, 6 datos, 2 documentos, 2 audio, 2 otros.

## 3. Qué commitear
**Prompt:** y que deberia commitear de esto?

**Resumen de la respuesta:** Recomendación: commitear `extraer_ordenar.sh` y `prompts_max.md`; no commitear `proyecto_analisis.zip` (47 MB, binario, es la entrada y no el resultado) ni la carpeta de salida. Sugerido agregarlos a `.gitignore`.
