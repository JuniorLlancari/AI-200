#!/bin/bash
# Unit: Exercise - Build and manage a container image with ACR Tasks
# Flujo end-to-end independiente (grupo de recursos propio)
#
# Recordatorio rápido de "ACR Task" (detalle completo en 02-build-run-acr-tasks.sh):
# es el motor de build/automatización propio del registry -- corre en la nube, no en tu
# Docker local. "az acr build" = ejecución única bajo demanda (Quick Task). "az acr task
# create" = recurso persistente que queda guardado y se puede disparar por schedule (cron).

az group create -n rg-laboratorio-001 -l eastus
az acr create -n acrlab001 -g rg-laboratorio-001 --sku Basic

# Quick Task: build de la imagen en el registry (sin Docker local) usando el Dockerfile
# del directorio actual (".") como contexto.
az acr build -r acrlab001 -t interference-api:v1.0.0 .
az acr login -n acrlab001
docker pull acrlab001.azurecr.io/interference-api:v1.0.0
docker run acrlab001.azurecr.io/interference-api:v1.0.0

# Trazabilidad de la imagen con Run.ID: "{{.Run.ID}}" es una variable que ACR Tasks
# sustituye en tiempo de build por el ID único de esa ejecución -- así el tag de la imagen
# queda ligado al run que la generó (útil para auditar qué build produjo qué imagen).
az acr build -r acrlab001 -t "interference-api:v1.0.0-{{.Run.ID}}" .

# Task programada (recurso persistente, no una ejecución única): -t/--image le da el tag de
# salida cuando el task SÍ produce una imagen; --cmd aquí es un comando simulado en vez de
# un build real; --schedule "0 0 * * *" = todos los días a medianoche (cron).
az acr task create -n nightly-build-lab -r acrlab001 -t interference-api:nightly --context /dev/null --schedule "0 0 * * *" --cmd "echo 'build simulado'"
# Sobreescribe el timer "t1" del task a "cada minuto" solo para poder ver runs en el lab
# sin esperar hasta medianoche.
az acr task timer update -n nightly-build-lab -r acrlab001 --timer-name t1 --schedule "* * * * *"
# Historial de ejecuciones del task (cada disparo del timer genera una fila nueva aquí).
az acr task list-runs -r acrlab001 -o table

# Limpieza al terminar el ejercicio: borra TODO el grupo de recursos, incluyendo el task
# programado -- si no se hiciera, el task seguiría disparándose solo cada minuto para siempre.
az group delete -n rg-laboratorio-001 -y --no-wait
