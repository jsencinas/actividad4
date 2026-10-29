# Especificación: Script de organización y auditoría de código (cv2)

## Objetivo

Crear un script en **Bash** que organice archivos por tipo y luego audite los
archivos Python resultantes para detectar el uso de la librería de visión por
computadora **OpenCV (`cv2`)**.

---

## Paso 1 — Organización de archivos

El script debe empezar llamando a `extraer_orderar.sh`.

> **Nota:** `extraer_orderar.sh` todavía no está en el repositorio. Supón que
> ya existe y que funciona como se describe abajo.

Al ejecutarse, `extraer_orderar.sh` crea subcarpetas dentro del **directorio
destino** según las extensiones que encuentre y mueve cada archivo a la que le
corresponde. Puede organizarlos de dos formas:

| Por categoría  | Por extensión |
| -------------- | ------------- |
| `documentos/`  | `txt/`        |
| `imagenes/`    | `jpg/`        |
| `codigo/`      | `py/`         |
| `otros/`       | …             |

---

## Paso 2 — Auditoría de código

Con los archivos ya organizados, el script debe:

1. **Recorrer solo los archivos `.py`**: usar su carpeta o filtrar por extensión.
2. **Buscar términos clave** de visión por computadora o procesamiento de imágenes:
   - `cv2`
   - `import cv2`
   - `opencv`

### Salida en terminal (por cada archivo `.py`)

| Dato              | Descripción                                                   |
| ----------------- | ------------------------------------------------------------- |
| Archivo           | Nombre o ruta del archivo analizado                           |
| ¿Contiene `cv2`?  | Sí / No                                                       |
| Coincidencias     | Número de línea y la línea exacta de cada coincidencia (`grep -n`) |

### Resumen final

Al terminar, mostrar:

- Total de archivos `.py` analizados.
- Cuántos de ellos usan la librería `cv2`.

---

## Ejemplo de salida esperada

```text
Archivo: destino/py/vision.py
  Contiene cv2: SÍ
    Línea 1: import cv2
    Línea 2: img = cv2.imread("a.jpg")

Archivo: destino/py/hola.py
  Contiene cv2: NO

==================== RESUMEN ====================
Archivos .py analizados:  2
Archivos que usan cv2:    1
=================================================
```
