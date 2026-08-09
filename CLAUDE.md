# ai-200

Repositorio personal de práctica para el curso oficial de Microsoft **AI-200T00 "Develop AI cloud solutions on Azure"** (https://learn.microsoft.com/en-us/training/courses/ai-200t00). No es una app ni una librería — son scripts de laboratorio (`az` CLI) organizados por módulo/unidad del curso, más algunas imágenes de ejemplo (Python y .NET) usadas como carga de trabajo en esos labs.

## Estructura

- **`Indice.json`** — índice maestro que espeja la lista oficial de módulos/submódulos/unidades del curso (`Modules[].SubModules[].Units[]`), con `Order` como string zero-padded para ordenar. Mantenerlo como mirror fiel del curso, no como tracker de progreso (sin campos `completado`/`notas` agregados especulativamente). Ojo: la clave `Tittle` es un typo del propio índice — dejarlo así salvo que se pida corregir explícitamente.
- **`ModuloNN/`** — carpeta de práctica por módulo (Order en `Indice.json`). Dentro, una subcarpeta por submódulo: `<Order>-<kebab-case-nombre>` (ej. `Modulo01/01-store-manage-containers-acr`).
- **Dentro de cada submódulo:**
  - Un `README.md` con tabla archivo → Unit que cubre.
  - Un `.sh` por Unit práctica, numerado `NN-kebab-unit-name.sh`. Son **secuenciales por defecto** (mismo resource group entre ellos dentro del submódulo), excepto el script de la unidad "Exercise", que es **end-to-end independiente**: crea su propio resource group y termina con `az group delete ... -y --no-wait`.
  - `dockerfile` + código de ejemplo en Python (Flask) — la imagen que usan los labs.
  - `dotnet/` — la misma app equivalente en ASP.NET Core minimal API (`net10.0`), con su propio `Dockerfile` multi-stage. No la referencian los `.sh` (Python sigue siendo el default); el comando de build alternativo (`az acr build ... ./dotnet`) va documentado solo en el `README.md` del submódulo.
- **`ShortParameters.md`** — referencia de flags cortas de `az` (`-g`, `-n`, `-r`, etc.) por grupo de comandos. **No confiar ciegamente**: ya tuvo más de un dato desactualizado (ver historial de commits); verificar siempre con `az <comando> --help` contra el CLI instalado antes de asumir que algo "no tiene forma corta".
- **`WSL_vs_Windows.md`** — notas de referencia, no código.
- **`Apuntes.sh`** — notas/comandos sueltos de scratch, no un lab estructurado.

## Convenciones al escribir/editar `.sh`

- Usar siempre la forma corta de cada flag cuando exista (verificar con `--help`, no con `ShortParameters.md` a ciegas). Orden fijo cuando aplican ambos: `-n` primero, `-g` segundo, luego el resto de flags en el orden que corresponda al comando.
- Comentarios en español, explicando el *qué/por qué* de banderas y conceptos no obvios (ej. qué es un ACR Task, qué es un deployment slot) — no solo repetir el nombre del comando.
- No inventar ejercicios prácticos nuevos por iniciativa propia; reorganizar/documentar lo que ya existe, y solo llenar huecos de cobertura de Units cuando se pida explícitamente.
- Antes de mover/renombrar archivos de laboratorio del usuario, confirmar primero (no hay backups salvo git).

## Git

- `.gitignore` excluye `ModuloNN/` que todavía no se terminó de practicar (hoy: `Modulo02/`). Se va sacando del ignore (o agregando excepciones) módulo por módulo a medida que se completa — no subir trabajo a medio hacer.
- CLI de referencia usado para verificar comandos: `az` 2.67.0.
