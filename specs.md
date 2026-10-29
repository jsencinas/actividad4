# Especificación: Script de organización y auditoría de código (PySide6)

## Objetivo

Crear un script en **Bash** que organice archivos por tipo y luego audite los
archivos Python resultantes para detectar el uso de la librería de interfaces
gráficas **PySide6**.

---

## Paso 1 — Organización de archivos

El script debe empezar llamando a `extraer_ordenar.sh` con dos argumentos:

```bash
./extraer_ordenar.sh <archivo.zip> <directorio_destino>
```

`extraer_ordenar.sh` extrae el zip y crea subcarpetas dentro del **directorio
destino** según la extensión de cada archivo:

| Carpeta        | Extensiones (ejemplos)          |
| -------------- | ------------------------------- |
| `codigo/`      | `py`, `js`, `sh`, `c`, `java`   |
| `imagenes/`    | `png`, `jpg`, `gif`, `svg`      |
| `documentos/`  | `pdf`, `docx`, `txt`, `md`      |
| `datos/`       | `csv`, `xlsx`, `json`, `xml`    |
| `audio/`       | `mp3`, `wav`, `ogg`             |
| `otros/`       | Todo lo demás                   |

---

## Paso 2 — Auditoría de código

Con los archivos ya organizados, el script debe:

1. **Recorrer solo los archivos `.py`**: usar su carpeta o filtrar por extensión.
2. **Buscar el uso de la librería PySide6**, por ejemplo:
   - `import PySide6`
   - `from PySide6 import ...`
   - `from PySide6.QtWidgets import ...`

### Salida en terminal (por cada archivo `.py`)

| Dato                  | Descripción                                                        |
| --------------------- | ------------------------------------------------------------------ |
| Archivo               | Nombre o ruta del archivo analizado                                |
| ¿Contiene `PySide6`?  | Sí / No                                                            |
| Coincidencias         | Número de línea y la línea exacta de cada coincidencia (`grep -n`) |

### Resumen final

Al terminar, mostrar:

- Total de archivos `.py` analizados.
- Cuántos de ellos usan la librería `PySide6`.

---

## Ejemplo de salida esperada

```text
Archivo: destino/codigo/ventana.py
  Contiene PySide6: SÍ
    Línea 1: from PySide6.QtWidgets import QApplication, QLabel

Archivo: destino/codigo/hola.py
  Contiene PySide6: NO

==================== RESUMEN ====================
Archivos .py analizados:   2
Archivos que usan PySide6: 1
Archivos sin PySide6:      1
=================================================
```
