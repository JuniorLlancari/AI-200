# Submódulo 02 — Deploy containers to Azure App Service

Ejemplos prácticos para el submódulo de Order 2 del Módulo 01 (`Indice.json`). `01` a `04` son secuenciales sobre `rg-appservice-lab`/`docprocessor-lab-001` (`04` termina borrando ese grupo); `05` es el ejercicio, independiente, con su propio resource group `rg-slots-lab`.

## Archivos

| Archivo | Unit que cubre |
|---|---|
| `01-deploy-app-service.sh` | Deploy containers to Azure App Service |
| `02-configure-runtime.sh` | Configure container runtime behavior |
| `03-configure-app-settings.sh` | Configure application settings |
| `04-observe-troubleshoot.sh` | Observe and troubleshoot containerized apps |
| `05-exercise-deployment-slots.sh` | Exercise - Deploy a container to Azure App Service (deployment slots, swap) |
| `app.py`, `dockerfile` | Imagen de ejemplo (Flask) usada en los deploys |
| `dotnet/` | Misma app (`/`, `/health`, env vars `ENVIRONMENT`/`DB_PASSWORD`/`PORT`), versión .NET 10 (minimal API). Build: `az acr build -r acrappsvclab -t app-documentor-dotnet:v01 ./dotnet` |
| `settings.json` | Salida de ejemplo de `az webapp config appsettings list` (generada por `03`) |

`Introduction`, `Module assessment` y `Summary` no tienen ejercicio (son teoría/quiz).
