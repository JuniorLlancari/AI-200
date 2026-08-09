#!/bin/bash
# Unit: Observe and troubleshoot containerized apps
# Requiere docprocessor-lab-001 de 01-deploy-app-service.sh

# Activa que los logs de STDOUT/STDERR del contenedor se guarden en el filesystem de App Service
#  -- sin esto, "log tail" no tendría nada que mostrar de la salida del contenedor.
az webapp log config -n docprocessor-lab-001 -g rg-appservice-lab --docker-container-logging filesystem
# Streaming en vivo de esos logs (equivalente a "docker logs -f" pero contra la app en Azure).
az webapp log tail -n docprocessor-lab-001 -g rg-appservice-lab
# Reinicia la Web App (útil tras cambiar configuración, o para forzar que relea env vars).
az webapp restart -n docprocessor-lab-001 -g rg-appservice-lab

# Otras herramientas de diagnóstico (no dependen de esta Web App puntual, son de exploración
# general para resolver problemas de capacidad/cuota antes de crear o escalar recursos):
# Solo muestra la ayuda del comando (no despliega nada) -- referencia rápida de cómo se
# haría un deploy por ZIP en vez de por contenedor, sin ejecutarlo.
az webapp deployment source config-zip --help
# Lista las regiones donde el SKU B1 está disponible -- útil antes de elegir -l en "plan create".
az appservice list-locations --sku B1 -o table
# Muestra el uso de cuotas de cómputo (cores, IPs, etc.) en la región -- ayuda a diagnosticar
# errores de "cuota excedida" al crear planes/VMs en esa región.
az vm list-usage -l canadacentral -o table

# Limpieza al terminar
az group delete -n rg-appservice-lab -y --no-wait
