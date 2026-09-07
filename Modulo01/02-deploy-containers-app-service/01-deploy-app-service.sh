#!/bin/bash
# Unit: Deploy containers to Azure App Service

# --- LOCAL: validar la imagen antes de subirla a Azure ---
# Construye la imagen con Docker local usando el Dockerfile dentro de ./dotnet (build context).
docker build -t app-documentor ./dotnet
# Lista las imágenes locales, para confirmar que "app-documentor" quedó creada.
docker image ls
# Levanta un contenedor de prueba en background (-d) mapeando el puerto local 5000 al
# puerto 8000 dentro del contenedor (el que expone la app), con nombre "doc-app".
docker run -d -p 5000:8000 --name doc-app app-documentor
# Sigue los logs del contenedor en vivo (-f = follow), para confirmar que arrancó bien.
docker logs -f doc-app
# Detiene el contenedor de prueba una vez validado (ya cumplió su propósito local).
docker stop doc-app

# --- AZURE: build en ACR y deploy a App Service ---
az group create -n rg-appservice-lab -l canadacentral
az acr create -n acrappsvclab -g rg-appservice-lab --sku Basic
# Reconstruye la MISMA imagen pero en la nube (ACR), para que App Service pueda tirar de
# ella sin depender de que exista en tu Docker local.
az acr build -r acrappsvclab -t app-documentor:v01 ./dotnet

# App Service Plan: el "servidor"/conjunto de cómputo (CPU, RAM) donde corren una o más Web Apps.
# --sku B1 = nivel Basic (sin autoscale, sin slots de deployment ilimitados, más económico); 
# --is-linux porque los contenedores Linux requieren un plan Linux, no Windows.
az appservice plan create -n plan-appservice-lab -g rg-appservice-lab --sku B1 --is-linux
# La Web App en sí: el recurso que efectivamente corre la imagen. -c (--container-image-name)
# le dice de qué imagen (registry/repo:tag) tirar al arrancar.
az webapp create -n docprocessor-lab-001 -g rg-appservice-lab -p plan-appservice-lab \
  -c acrappsvclab.azurecr.io/app-documentor:v01

# Managed identity para autenticar contra ACR sin usuario/contraseña.
# "identity assign" crea una identidad de Azure AD propia de esta Web App (sin credenciales  que manejar a mano);
# luego brindamos permiso "AcrPull" sobre el registry para que pueda jalar imágenes usando esa identidad en vez de user/password.
az webapp identity assign -n docprocessor-lab-001 -g rg-appservice-lab
principalId=$(az webapp identity show -n docprocessor-lab-001 -g rg-appservice-lab --query principalId -o tsv)
acrId=$(az acr show -n acrappsvclab --query id -o tsv)
az role assignment create --assignee $principalId --scope $acrId --role AcrPull

# Le dice a App Service que use la managed identity (en vez de user/password) para
# autenticar los pulls contra ACR -- sin esto, la identidad creada arriba no se usaría.
az webapp config set -n docprocessor-lab-001 -g rg-appservice-lab \
  --generic-configurations '{"acrUseManagedIdentityCreds": true}'
# WEBSITES_PORT: variable especial que App Service lee para saber a qué puerto interno del
# contenedor debe reenviar el tráfico HTTP entrante (aquí, el 8000 que expone la imagen).
az webapp config appsettings set -n docprocessor-lab-001 -g rg-appservice-lab --settings WEBSITES_PORT=8000
az webapp config appsettings set -n docprocessor-lab-001 -g rg-appservice-lab --settings ENVIRONMENT=produccion


 
