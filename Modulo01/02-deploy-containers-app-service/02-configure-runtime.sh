#!/bin/bash
# Unit: Configure container runtime behavior
# Requiere docprocessor-lab-001 de 01-deploy-app-service.sh

# healthCheckPath: ruta que App Service pega periódicamente para confirmar que la app
# sigue viva; si deja de responder 200, App Service reinicia la instancia automáticamente
# (y en un plan con varias instancias, saca esa instancia del balanceo hasta que se recupere).
az webapp config set -n docprocessor-lab-001 -g rg-appservice-lab \
                      --generic-configurations '{"healthCheckPath": "health"}'
# --always-on true: evita que App Service "duerma" la app por inactividad (por defecto se
# descarga de memoria tras ~20 min sin requests); sin esto, el primer request tras estar
# dormida tarda más (cold start). No aplica en el tier Free/Shared, solo desde Basic (B1+).
az webapp config set  -n docprocessor-lab-001 -g rg-appservice-lab --always-on true

# -e (--enable-cd) true: activa un webhook de Continuous Deployment -- cuando ACR publica un tag
# nuevo en la misma imagen que usa esta Web App, App Service se entera y redepliega solo,
# sin necesitar correr "az webapp config container set" manualmente cada vez.
az webapp deployment container config -n docprocessor-lab-001 -g rg-appservice-lab -e true

# Cambiar el puerto que expone el contenedor (WEBSITES_PORT es una env var especial de App Service)
az webapp config appsettings set -n docprocessor-lab-001 -g rg-appservice-lab --settings WEBSITES_PORT=9999

# Ver la configuración de runtime resultante
az webapp config show           -n docprocessor-lab-001 -g rg-appservice-lab --query "acrUseManagedIdentityCreds"
az webapp config container show -n docprocessor-lab-001 -g rg-appservice-lab
