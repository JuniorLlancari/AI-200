# Submódulo 01 — Store and manage containers in Azure Container Registry

Ejemplos prácticos para el submódulo de Order 1 del Módulo 01 (`Indice.json`). Los tres primeros scripts son secuenciales (mismo registry `acrlab002`); el ejercicio final corre en su propio resource group.

## Archivos

| Archivo | Unit que cubre |
|---|---|
| `01-registries-repositories-artifacts.sh` | Registries, repositories, and artifacts |
| `02-build-run-acr-tasks.sh` | Build and run images with ACR Tasks |
| `03-tag-version-images.sh` | Tag and version images |
| `04-exercise-build-manage-acr-tasks.sh` | Exercise - Build and manage a container image with ACR Tasks (flujo end-to-end independiente) |
| `dockerfile` | Imagen usada por los builds de ACR (Python) |
| `dotnet/` | Misma imagen `inference-api`, versión .NET 10 (minimal API). Build: `az acr build -r acrlab002 -t inference-api-dotnet:v1 ./dotnet` |

`Introduction`, `Module assessment` y `Summary` no tienen ejercicio (son teoría/quiz).
