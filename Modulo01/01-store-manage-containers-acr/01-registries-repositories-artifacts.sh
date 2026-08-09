#!/bin/bash
# Unit: Registries, repositories, and artifacts
#
# Jerarquía de ACR: un REGISTRY (ej. "acrlab002") es la cuenta/servicio en sí; dentro
# contiene uno o varios REPOSITORIES (ej. "inference-api", uno por nombre de imagen); y
# cada repository contiene uno o varios ARTIFACTS (cada combinación imagen:tag concreta,
# ej. "inference-api:v1.0.0"). Es el mismo modelo mental que Docker Hub: registry = servidor,
# repository = carpeta del proyecto, artifact = versión publicada dentro de esa carpeta.

# Grupo de recursos donde vivirá todo el laboratorio de este módulo.
az group create -n rg-ai200-lab -l eastus

# Login de Docker contra el registro (necesario para pulls/pushes manuales)
az acr login -n acrlab002

# --sku Basic: el nivel más económico de ACR (throughput y storage limitados); alcanza
# para labs/dev. Los otros niveles (Standard, Premium) suman más throughput, geo-replicación
# y features como content trust -- no hacen falta aquí.
az acr create -n acrlab002 -g rg-ai200-lab --sku Basic

# Build inicial para tener al menos un repositorio con una imagen
az acr build -r acrlab002 -t inference-api:v1.0.0 .

# Explorar la jerarquía: registry -> repository -> artifact (imagen/tag)
# Lista los repositories que existen dentro del registry (un nombre por cada imagen distinta).
az acr repository list -n acrlab002 -o table
# Lista los tags (artifacts) que existen dentro de un repository puntual.
az acr repository show-tags -n acrlab002 --repository inference-api -o table
# Detalle de UN artifact específico (repository + tag): tamaño, digest, fecha de creación, etc.
az acr repository show -n acrlab002 -t inference-api:v1.0.0 -o jsonc

# Pull/run manual (equivalente a lo que haría un consumidor externo del registry)
docker pull acrlab002.azurecr.io/inference-api:v1.0.0
docker run acrlab002.azurecr.io/inference-api:v1.0.0
