#!/bin/bash
# Unit: Configure application settings
# Requiere docprocessor-lab-001 de 01-deploy-app-service.sh

# App settings = variables de entorno propias de la app (no son configuración de runtime
# de App Service en sí); se inyectan al contenedor como env vars normales. Se pueden pasar
# varios pares clave=valor de una vez en el mismo --settings.
az webapp config appsettings set -n docprocessor-lab-001 -g rg-appservice-lab \
  --settings LOG_LEVEL=INFO MAX_DOCUMENT_SIZE_MB=50

# Exporta todos los app settings actuales a un archivo local (útil para respaldo o para
# revisar qué quedó configurado sin tener que leer la salida de la terminal).
az webapp config appsettings list -n docprocessor-lab-001 -g rg-appservice-lab -o json > settings.json

# --- Slot settings ("sticky"): requieren un slot, ver 05-exercise-deployment-slots.sh ---
# Sin --slot-settings: la variable viaja con el swap (comportamiento normal)
az webapp config appsettings set -n docprocessor-slots-001 -g rg-slots-lab --settings API_KEY=abc123
# Con --slot-settings: la variable queda marcada "sticky" y NO viaja con el swap
az webapp config appsettings set -n docprocessor-slots-001 -g rg-slots-lab --slot-settings ENVIRONMENT=produccion
