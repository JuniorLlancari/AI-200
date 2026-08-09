#!/bin/bash
# Unit: Exercise - Deploy a container to Azure App Service
# Flujo end-to-end independiente con deployment slots (staging -> production)

az group create -n rg-slots-lab -l canadacentral
az acr create   -n acrslotslab -g rg-slots-lab --sku Basic
az acr build    -r acrslotslab -t docprocessor:v1 .

# --sku S1 (Standard, no B1/Basic): los deployment slots requieren como mínimo el tier
# Standard -- Basic no los soporta, por eso este ejercicio no reutiliza el plan B1 anterior.
az appservice plan create -n plan-slots-lab         -g rg-slots-lab --sku S1 --is-linux
az webapp          create -n docprocessor-slots-001 -g rg-slots-lab -p plan-slots-lab  \
  --container-image-name acrslotslab.azurecr.io/docprocessor:v1

# Confirma que el plan quedó en Standard (S1) antes de intentar crear el slot.
az appservice plan show         -n plan-slots-lab -g rg-slots-lab --query "sku.name" -o tsv
# Un deployment slot es una copia "hermana" de la Web App con su propio hostname, donde se
# puede probar una versión nueva sin afectar producción; "staging" es solo el nombre elegido
# para este slot (no es un nombre reservado).
az webapp deployment slot create -n docprocessor-slots-001 -g rg-slots-lab  --slot staging

# Producción y staging tienen cada uno su propia managed identity
az webapp identity assign -n docprocessor-slots-001 -g rg-slots-lab
principalIdProd=$(az webapp identity show -n docprocessor-slots-001 -g rg-slots-lab --query principalId -o tsv)

az webapp identity assign -n docprocessor-slots-001 -g rg-slots-lab --slot staging
principalIdStaging=$(az webapp identity show -n docprocessor-slots-001 -g rg-slots-lab --slot staging --query principalId -o tsv)

acrId=$(az acr show -n acrslotslab --query id -o tsv)
az role assignment create --assignee $principalIdProd --scope $acrId --role AcrPull
az role assignment create --assignee $principalIdStaging --scope $acrId --role AcrPull

az webapp config set -n docprocessor-slots-001 -g rg-slots-lab --generic-configurations '{"acrUseManagedIdentityCreds": true}'
az webapp config set -n docprocessor-slots-001 -g rg-slots-lab --slot staging --generic-configurations '{"acrUseManagedIdentityCreds": true}'

# Sin el parametro --slot → va al slot de producción (el implícito)
# --slot-settings  -> variable de entorno es específica de ese slot, y no se "intercambia" al hacer swap.
# --settings -> variable de entorno que se muesve al haceer swap.
az webapp config appsettings set -n docprocessor-slots-001 -g rg-slots-lab --slot-settings ENVIRONMENT=produccion 
az webapp config appsettings set  -n docprocessor-slots-001 -g rg-slots-lab --slot staging --settings APP_VERSION="1.1.0"
az webapp config appsettings set -n docprocessor-slots-001 -g rg-slots-lab --slot staging --slot-settings ENVIRONMENT=staging

# Actualizar staging con una nueva versión de la imagen
az acr build -r acrslotslab -t docprocessor:v2 .
az webapp config container set -n docprocessor-slots-001 -g rg-slots-lab --slot staging \
  --docker-custom-image-name acrslotslab.azurecr.io/docprocessor:v2

az webapp config container show -n docprocessor-slots-001 -g rg-slots-lab
az webapp config container show -n docprocessor-slots-001 -g rg-slots-lab --slot staging

# Swap: (staging) slot de origen -> (production) slot de destino
# --slot staging           -> 	El slot de origen
# --target-slot production ->   El slot de destino
az webapp deployment slot swap -n docprocessor-slots-001 -g rg-slots-lab --slot staging --target-slot production
 
# Limpieza al terminar el ejercicio
az group delete -n rg-slots-lab -y --no-wait
