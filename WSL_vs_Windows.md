# Diferencias Windows vs Linux en WSL — Notas técnicas

Guía de referencia sobre las diferencias entre Windows y Linux que más problemas causan cuando se trabaja en WSL, con el caso real de `az` CLI como ejemplo.

---

## 1. ¿Qué es WSL y por qué "conviven" dos mundos?

WSL (Windows Subsystem for Linux) da acceso a una terminal Linux **dentro** de Windows, pero permite que ambos sistemas se "vean" entre sí:

- El disco de Windows (`C:\`) está montado en Linux bajo `/mnt/c/`.
- WSL tiene una función llamada **interop**, que agrega automáticamente el `PATH` de Windows al `PATH` de la terminal Linux. Esto permite ejecutar programas de Windows (`notepad.exe`, `az.exe`, etc.) desde bash — cómodo, pero fuente de confusión si no se sabe que está pasando.

---

## 2. El `PATH` y por qué importa el orden

El `PATH` es la lista de carpetas donde el sistema busca un programa cuando se escribe su nombre. Al escribir un comando, el sistema recorre esa lista **en orden** y ejecuta el primer binario que encuentra con ese nombre.

Ejemplo real:

```bash
which -a az
```
```
/usr/bin/az                                              ← az de Linux (nativo)
/bin/az                                                  ← symlink al mismo binario
/mnt/c/Program Files/Microsoft SDKs/Azure/CLI2/wbin/az   ← az de Windows
```

Si solo existe la ruta bajo `/mnt/c/...`, cada vez que se escribe `az` en WSL en realidad se ejecuta el **binario de Windows**, no uno de Linux — aunque la terminal sea bash.

**Solución:** instalar la versión nativa de Linux del programa y verificar que su ruta (`/usr/bin/...`) aparezca *antes* que cualquier ruta `/mnt/c/...` en el PATH.

```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

---

## 3. CRLF vs LF: la diferencia que rompe scripts

La causa raíz de muchos errores "invisibles" al mezclar Windows y Linux.

| Sistema | Fin de línea | Nombre |
|---|---|---|
| Windows | `\r\n` (Carriage Return + Line Feed) | CRLF |
| Linux / macOS | `\n` (Line Feed) | LF |

Es una diferencia heredada de las máquinas de escribir: `\r` regresaba el cabezal al inicio de línea, `\n` bajaba una línea. Windows nunca dejó de usar ambos; Unix simplificó a solo `\n`.

### Cómo esto rompe un comando en apariencia idéntico

```bash
runId=$(az acr task list-runs -r acrlab002 --query "[0].runId" -o tsv)
```

Si el `az` ejecutado es el de **Windows**, su salida viene con el estilo `ca5\r\n`. Bash elimina automáticamente el `\n` final al capturar con `$(...)`, **pero no el `\r`**, porque no es un separador de línea para Linux — es solo "otro carácter" dentro del texto.

Resultado: `runId` queda como `"ca5\r"`, no `"ca5"`.

- Al hacer `echo $runId` se ve **idéntico** a `ca5`, porque el `\r` mueve el cursor pero no imprime nada visible.
- Al comparar strings exactamente (como hace cualquier API o CLI al buscar un ID), `"ca5\r" ≠ "ca5"` — de ahí errores como *"no se encontró el recurso"* con un valor que a simple vista es correcto.

### Cómo diagnosticarlo

```bash
echo -n "$runId" | wc -c       # cuenta caracteres reales
echo -n "ca5" | wc -c          # compara contra el valor esperado
```

Si el primero da un número mayor, hay caracteres extra (casi siempre `\r`).

```bash
echo -n "$runId" | xxd | head  # ver bytes en hexadecimal
```
Buscar `0d` (carriage return) antes del `0a` (line feed) confirma el problema.

### Cómo arreglarlo (parche rápido, sin cambiar de binario)

```bash
runId=$(az acr task list-runs -r acrlab002 --query "[0].runId" -o tsv | tr -d '\r')
```

`tr -d '\r'` elimina cualquier retorno de carro de la salida antes de asignarla a la variable.

### Solución de raíz

Usar el binario nativo de Linux (ver punto 2) — su salida ya viene en formato `\n` puro, sin `\r`, así que no hace falta ningún parche.

---

## 4. Otras diferencias Windows/Linux que suelen generar problemas en WSL

### 4.1 Mayúsculas y minúsculas en nombres de archivo
- **Linux**: sensible a mayúsculas (`Archivo.txt` ≠ `archivo.txt`, son dos archivos distintos).
- **Windows**: no distingue (`Archivo.txt` = `archivo.txt`).
- Riesgo: crear/editar archivos desde Windows y luego no encontrarlos "por nombre exacto" desde Linux, o duplicados accidentales.

### 4.2 Separador de rutas
- **Windows**: `\` (backslash) — `C:\Users\nombre`
- **Linux**: `/` (forward slash) — `/home/nombre`
- Dentro de WSL, siempre se usa `/`, incluso para rutas que apuntan al disco de Windows (`/mnt/c/Users/nombre`).

### 4.3 Permisos de archivos
- Linux usa permisos tipo Unix (lectura/escritura/ejecución para usuario/grupo/otros — `chmod`, `chown`).
- Windows usa ACLs (listas de control de acceso) distintas.
- Archivos creados desde Windows y accedidos desde `/mnt/c/` en WSL a veces muestran permisos "raros" (todo con `777` o sin bit de ejecución) porque WSL traduce las ACLs de NTFS a permisos Unix de forma aproximada.

### 4.4 Variables de entorno
- Windows: `%VARIABLE%` en cmd, `$env:VARIABLE` en PowerShell.
- Linux: `$VARIABLE` en bash/zsh.
- No son intercambiables directamente; cada shell tiene su propia sintaxis.

### 4.5 Codificación de caracteres
- Windows tradicionalmente usa codificaciones como `CP1252` o `UTF-16` en muchas herramientas nativas (notepad, algunos scripts `.bat`).
- Linux usa `UTF-8` casi universalmente.
- Puede causar caracteres raros (acentos, ñ) al mover archivos de texto entre ambos sistemas si no se fuerza UTF-8.

### 4.6 Rendimiento de archivos entre sistemas
- Acceder a archivos de Linux desde Windows (`\\wsl$\...`) o de Windows desde Linux (`/mnt/c/...`) es **más lento** que quedarse dentro del mismo sistema de archivos nativo, porque cada acceso cruza la capa de traducción entre ambos.
- Buena práctica: para proyectos de desarrollo pesados (node_modules, compilaciones, etc.), trabajar dentro del filesystem nativo de Linux (`/home/usuario/...`), no en `/mnt/c/...`.

### 4.7 Ejecutables y extensiones
- Windows identifica ejecutables por extensión (`.exe`, `.bat`, `.cmd`).
- Linux identifica ejecutables por el **bit de ejecución** (`chmod +x archivo`), sin importar la extensión (o la ausencia de ella).
- Por eso en Linux es común ver comandos sin extensión (`az`, `python3`, `git`) mientras que su equivalente en Windows sí la tiene (`az.cmd`, `python.exe`, `git.exe`).

---

## 5. Resumen rápido del caso real (`az` en WSL)

1. WSL agrega automáticamente el PATH de Windows al de Linux (interop).
2. Sin el `az` nativo instalado, `az` en WSL ejecutaba el binario de **Windows** (`/mnt/c/.../az`).
3. Ese binario generaba su salida con formato **CRLF** (`\r\n`), típico de Windows.
4. Bash solo elimina el `\n` al capturar con `$(...)`, dejando el `\r` pegado al valor.
5. Visualmente (`echo`) se veía igual, pero como string exacto era distinto → comparaciones fallaban.
6. Instalar `az` nativo de Linux (`/usr/bin/az`) y asegurar que aparezca primero en el PATH resolvió el problema de raíz, porque su salida usa **LF puro**, sin `\r`.