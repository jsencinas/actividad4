# actividad4

Herramienta en **Bash** que extrae un archivo `.zip`, organiza su contenido en
carpetas según el tipo de archivo y después audita el código Python para
detectar qué archivos usan la librería de interfaces gráficas **PySide6**. Los
archivos que la usan se mueven a `codigo/pyside6/`.

El proyecto se construyó en dos partes, cada una a partir de un prompt. Abajo
están los dos prompts organizados y la síntesis de cómo se combinan.

---

## Estructura del repositorio

| Archivo                | Descripción                                                    |
| ---------------------- | -------------------------------------------------------------- |
| `extraer_ordenar.sh`   | Parte 1: extrae el zip y organiza los archivos por tipo        |
| `auditoria_pyside6.sh` | Parte 2: llama a la parte 1, audita los `.py` buscando PySide6 y mueve los que la usan a `codigo/pyside6/` |
| `prompts_max.md`       | Registro de prompts y respuestas de la parte 1                  |
| `specs.md`             | Especificación (prompt) de la parte 2                          |

---

## Prompts

### Prompt 1: organización de archivos (`extraer_ordenar.sh`)

> Analiza `proyecto_analisis.zip` y a partir de esto genera un script
> `extraer_ordenar.sh`. Debe recibir 2 argumentos: la ruta del archivo zip y la
> ruta del directorio donde se va a organizar la información. Las carpetas se
> deben organizar por tipo o extensión de archivo, por ejemplo: `documentos/`,
> `imagenes/`, `codigo/`, `otros/`.

**Requisitos:**
- Recibir exactamente dos argumentos: `<archivo.zip>` y `<directorio_destino>`.
- Validar que el zip exista y sea válido.
- Crear una subcarpeta por categoría dentro del destino y mover ahí cada archivo.

### Prompt 2: auditoría de código (`auditoria_pyside6.sh`)

> Genera un script en Bash que primero llame a `extraer_ordenar.sh`. Después debe
> hacer una auditoría de código: recorrer solo los archivos `.py`, buscar el uso
> de la librería **PySide6** y, por cada archivo, imprimir su nombre o ruta, si
> contiene la librería y el número y texto de cada línea donde aparece
> (`grep -n`). Al final, mostrar cuántos `.py` se analizaron y cuántos usan
> PySide6. Después, crear una subcarpeta `pyside6/` dentro de `codigo/` y mover
> ahí los archivos Python en los que se encontró la librería.

**Requisitos:**
- Ejecutar primero `extraer_ordenar.sh`.
- Analizar solo los archivos `.py`.
- Buscar `import PySide6`, `from PySide6 import ...` y `from PySide6.<módulo> import ...`.
- Imprimir el resultado de cada archivo y un resumen final.
- Mover los archivos que usan PySide6 a `codigo/pyside6/` sin sobrescribir los
  que ya existan.

La especificación completa está en [`specs.md`](specs.md) y el registro
de la parte 1 en [`prompts_max.md`](prompts_max.md).

---

## Síntesis

Los dos prompts forman una sola herramienta de dos etapas:

```
archivo.zip ──► extraer_ordenar.sh ──► destino/{codigo,imagenes,...} ──► auditoria_pyside6.sh ──► reporte PySide6
                                                                                     │
                                                                                     └──► destino/codigo/pyside6/
```

1. **Extracción y organización.** `auditoria_pyside6.sh` recibe el zip y el
   destino y se los pasa a `extraer_ordenar.sh`. Ese script los extrae en un
   directorio temporal, ignora los metadatos de macOS (`__MACOSX/`, `.DS_Store`,
   `._*`) y mueve cada archivo a su categoría:

   | Carpeta       | Extensiones                                                   |
   | ------------- | ------------------------------------------------------------- |
   | `codigo/`     | `py`, `js`, `ts`, `sh`, `c`, `cpp`, `h`, `java`, `html`, `css`, `sql`, `rb`, `go` |
   | `imagenes/`   | `png`, `jpg`, `jpeg`, `gif`, `webp`, `svg`, `bmp`, `ico`, `tiff` |
   | `documentos/` | `pdf`, `doc`, `docx`, `txt`, `md`, `ppt`, `pptx`, `odt`, `rtf` |
   | `datos/`      | `csv`, `xls`, `xlsx`, `json`, `xml`, `tsv`                    |
   | `audio/`      | `mp3`, `wav`, `ogg`, `flac`, `m4a`, `aac`                     |
   | `otros/`      | Todo lo demás, incluidos los archivos sin extensión          |

   Si ya existe un archivo con el mismo nombre, se agrega un sufijo (`_1`,
   `_2`, …) para no sobrescribirlo.

2. **Auditoría.** Con los archivos organizados, el script busca todos los
   `.py` dentro del destino y revisa cada uno con `grep -n` para encontrar
   `PySide6`. Para cada archivo imprime su ruta, si usa PySide6 y las líneas
   exactas donde aparece. Al final muestra el resumen.

3. **Separación.** Los archivos que usan PySide6 se mueven a la subcarpeta
   `codigo/pyside6/`. Si ya existe un archivo con el mismo nombre, se agrega un
   sufijo (`_1`, `_2`, …). Los que no usan PySide6 se quedan en `codigo/`.
   Si se vuelve a correr sobre el mismo destino, los que ya están en
   `pyside6/` no se vuelven a mover.

   ```text
   destino/
   ├── codigo/
   │   ├── pyside6/        ← .py que usan PySide6
   │   └── hola.py         ← .py que no usan PySide6
   ├── documentos/
   └── ...
   ```

---

## Uso

```bash
chmod +x extraer_ordenar.sh auditoria_pyside6.sh

# Organizar y auditar en un solo paso
./auditoria_pyside6.sh proyecto_analisis.zip destino

# Solo organizar
./extraer_ordenar.sh proyecto_analisis.zip destino
```

Ambos scripts deben estar en la misma carpeta. Se necesita `unzip` instalado.

### Ejemplo de salida

Con un zip que contiene `ventana.py`, `hola.py`, `notas.txt` y `foto.png`:

```text
==> Organizando archivos con extraer_ordenar.sh...
Listo: 4 archivos organizados en 'destino'
  codigo/      2
  documentos/  1
  imagenes/    1

==> Auditoría de código: buscando '\bPySide6\b' en archivos .py

Archivo: destino/codigo/hola.py
  Contiene PySide6: NO

Archivo: destino/codigo/ventana.py
  Contiene PySide6: SÍ
    Línea 1: from PySide6.QtWidgets import QApplication, QLabel
  Movido a: destino/codigo/pyside6/ventana.py

==================== RESUMEN ====================
Archivos .py analizados:   2
Archivos que usan PySide6: 1
Archivos sin PySide6:      1
Archivos con PySide6 en:   destino/codigo/pyside6/
=================================================
```

> **Nota:** `proyecto_analisis.zip` (47 MB) y la carpeta de salida no se
> incluyen en el repositorio.
