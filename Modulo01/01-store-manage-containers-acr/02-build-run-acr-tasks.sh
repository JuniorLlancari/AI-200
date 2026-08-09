#!/bin/bash
# Unit: Build and run images with ACR Tasks
# Requiere el registry acrlab002 de 01-registries-repositories-artifacts.sh
#
# ¿Qué es un "ACR Task"? Es un motor de build/automatización que vive DENTRO de
# Azure Container Registry: en vez de correr "docker build" en tu máquina, le pides
# al registry que corra el build (o cualquier comando) en un contenedor propio en la nube.
# Hay dos formas de usarlo:
#   1) Quick Task (az acr build): una ejecución única, bajo demanda, tipo "corre esto ahora".
#   2) Task (az acr task create): un RECURSO persistente que queda guardado en el registry
#      y se puede disparar solo, por triggers (schedule tipo cron, push a un repo git,
#      o actualización de la imagen base). Cada vez que se dispara, genera un "run" (una
#      ejecución) con su propio historial y logs, como un job de CI/CD dentro del registry.

# Quick Task: build en la nube, sin necesitar Docker local corriendo.
# Es "fire and forget": no queda un recurso Task registrado, solo el build y la imagen resultante.
az acr build -r acrlab002 -t inference-api:v1.1.0 .

# Task programada (recurso persistente) que en vez de construir una imagen, corre un
# comando suelto ("alpine date") sobre una imagen base pública -- útil para tareas de
# mantenimiento/lab, no para builds reales.
# --cmd: el comando que ejecuta el step del task (aquí, arrancar "alpine" y correr "date" dentro).
# --schedule "* * * * *": expresión cron (formato estándar min hora día mes día-semana) --
#   "cada minuto", solo para ver resultados rápido en el lab; en real sería algo como "0 2 * * *".
# --context /dev/null: no hay contexto de build (no hay Dockerfile que empaquetar), porque
#   este task no construye una imagen, solo ejecuta un comando.
az acr task create -n nightly-build-lab -r acrlab002 --cmd "alpine date" --schedule "* * * * *" --context /dev/null

# Variante: task que SÍ produce una imagen propia (-t/--image le da el tag de salida) en vez
# de solo correr un comando suelto. Sigue sin --context real porque --cmd reemplaza el build
# (aquí sería el punto donde normalmente iría "docker build" contra un Dockerfile real).
# Nota: -t (corto de --image) sí funciona aquí en az CLI 2.67.0, pese a lo que dice algún
# material antiguo -- verificado con "az acr task create --help".
az acr task create -n nightly-build-image -r acrlab002 -t inference-api:nightly --context /dev/null --schedule "0 0 * * *" --cmd "echo 'build simulado'"
# "acr task timer update" agrega/reemplaza un trigger de tipo temporizador (cron) al task ya
# creado -- un task puede tener varios timers con nombre (--timer-name); aquí se sobreescribe
# el schedule original (medianoche) por "cada minuto" para poder ver runs sin esperar un día.
az acr task timer update -n nightly-build-image -r acrlab002 --timer-name t1 --schedule "* * * * *"

# Inspecciona la definición del task: qué comando (step.cmd) ejecuta cada vez que se dispara.
az acr task show -n nightly-build-lab -r acrlab002 --query "step.cmd"

# Esperar 1-2 minutos y revisar las ejecuciones automáticas.
# "list-runs" es el HISTORIAL de ejecuciones del registry (incluye quick tasks y tasks
# programadas) -- cada fila es un run independiente con su propio ID, estado y duración.
az acr task list-runs -r acrlab002 -o table

# Logs de una ejecución específica (toma el run-id real de la tabla anterior).
# Cada run guarda su output de consola por separado, igual que un log de pipeline de CI/CD.
runId=$(az acr task list-runs -r acrlab002 --query "[0].runId" -o tsv)
az acr task logs -r acrlab002 --run-id $runId

# Borrar las tasks: al ser recursos persistentes con schedule, si no se borran siguen
# disparándose solas indefinidamente (y generando runs/costo) aunque cierres la terminal.
az acr task delete -n nightly-build-lab -r acrlab002 -y
az acr task delete -n nightly-build-image -r acrlab002 -y
