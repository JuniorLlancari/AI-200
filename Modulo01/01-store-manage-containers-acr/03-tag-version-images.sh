#!/bin/bash
# Unit: Tag and version images
# Requiere el registry acrlab002

# Tag único por build usando la variable Run.ID (comillas obligatorias por las llaves {})
az acr build -r acrlab002 -t "inference-api:v1.0.0-{{.Run.ID}}" .

# Digest de una imagen específica: identificador inmutable, independiente del tag
az acr repository show -n acrlab002 -t inference-api:v1.0.0 --query digest -o tsv

# Bloquear la imagen (lock) — solo disponible por CLI, no hay botón en el portal
az acr repository update -n acrlab002 -t inference-api:v1.0.0 --write-enabled false
az acr repository show -n acrlab002 -t inference-api:v1.0.0 -o jsonc

# Desbloquear cuando quieras seguir sobrescribiendo el tag
az acr repository update -n acrlab002 -t inference-api:v1.0.0 --write-enabled true

# "az acr run" ejecuta CUALQUIER comando dentro de un contenedor en el registry (como
# "az acr build" pero sin estar limitado a un build) -- aquí corre la herramienta interna
# "acr purge" para borrar imágenes huérfanas: --filter selecciona el repositorio por regex,
# --untagged limita el borrado a imágenes SIN ningún tag (quedaron sueltas tras overwrites),
# --ago 0d = sin margen de antigüedad (borra huérfanas ya mismo, no solo las de hace X días).
# El "/dev/null" final es el contexto de build, requerido por la sintaxis aunque no se use.
az acr run -r acrlab002 --cmd "acr purge --filter 'inference-api:.*' --untagged --ago 0d" /dev/null
