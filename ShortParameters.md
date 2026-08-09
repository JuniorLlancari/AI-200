# Azure CLI — Flags Cortos (Shorthand)

> Referencia rápida de los parámetros abreviados más usados, organizados por los comandos que ya practicamos (ACR, ACR Tasks, App Service, Resource Groups).

---

## Flags globales (aplican a casi todos los comandos)

| Largo | Corto | Uso |
|---|---|---|
| `--resource-group` | `-g` | Nombre del resource group |
| `--name` | `-n` | Nombre del recurso |
| `--location` | `-l` | Región de Azure |
| `--output` | `-o` | Formato de salida (`table`, `json`, `tsv`, `jsonc`) |
| `--subscription` | `-s`* | Suscripción específica (*ojo: en algunos comandos `-s` significa otra cosa, revisa el contexto) |
| `--query` | *(sin corto)* | Filtro JMESPath sobre el resultado |
| `--yes` | `-y`* | Confirmar sin preguntar (*no todos los comandos lo soportan) |
| `--help` | `-h` | Ayuda del comando |

---

## `az group` (Resource Groups)

```bash
az group create -n rg-lab -l eastus
```

| Largo | Corto |
|---|---|
| `--name` | `-n` |
| `--location` | `-l` |

---

## `az acr` (Container Registry)

```bash
az acr create -n acrlab001 -g rg-lab --sku Basic
az acr build -r acrlab001 -t inference-api:v1.0.0 .
```

| Comando | Largo | Corto |
|---|---|---|
| `acr create` | `--name` | `-n` |
| `acr create` | `--resource-group` | `-g` |
| `acr build` | `--registry` | `-r` |
| `acr build` | `--image` | `-t` |
| `acr repository show` | `--name` | `-n` |
| `acr repository show` | `--image` | `-t` |

⚠️ **Nota:** `--sku` **no tiene** versión corta en ningún comando `acr`.

---

## `az acr task` (ACR Tasks)

```bash
az acr task create -r acrlab001 -n nightly-build-lab --cmd "alpine date" --schedule "* * * * *"
```

| Largo | Corto |
|---|---|
| `--registry` | `-r` |
| `--name` | `-n` |
| `--cmd` | *(sin corto)* |
| `--schedule` | *(sin corto)* |
| `--context` | *(sin corto)* |
| `--image` | `-t` |

⚠️ **Corregido (verificado en az CLI 2.67.0):** `--image` **sí tiene corto (`-t`) también en `az acr task create`**, no solo en `az acr build`. El dato anterior de que "task create no tiene corto para --image" estaba desactualizado — confírmalo siempre con `az <comando> --help` en vez de confiar en esta tabla a ciegas.

---

## `az appservice plan` (App Service Plan)

```bash
az appservice plan create -n plan-lab -g rg-lab --sku B1 --is-linux
```

| Largo | Corto |
|---|---|
| `--name` | `-n` |
| `--resource-group` | `-g` |
| `--sku` | *(sin corto)* |
| `--is-linux` | *(sin corto, es flag booleano)* |

---

## `az webapp` (Web App / App Service)

```bash
az webapp create -g rg-lab -p plan-lab -n docprocessor-001 --container-image-name acrlab001.azurecr.io/docprocessor:v1
```

| Largo | Corto |
|---|---|
| `--resource-group` | `-g` |
| `--name` | `-n` |
| `--plan` | `-p` |
| `--container-image-name` | *(sin corto)* |
| `--runtime` | *(sin corto)* |

### `az webapp config appsettings set`

```bash
az webapp config appsettings set -g rg-lab -n docprocessor-001 --settings WEBSITES_PORT=8000
```

| Largo | Corto |
|---|---|
| `--resource-group` | `-g` |
| `--name` | `-n` |
| `--settings` | *(sin corto)* |
| `--slot-settings` | *(sin corto)* |

### `az webapp log`

```bash
az webapp log tail -g rg-lab -n docprocessor-001
```

| Largo | Corto |
|---|---|
| `--resource-group` | `-g` |
| `--name` | `-n` |

---

## `az keyvault`

```bash
az keyvault create -n kv-lab -g rg-lab -l eastus
```

| Largo | Corto |
|---|---|
| `--name` | `-n` |
| `--resource-group` | `-g` |
| `--location` | `-l` |

### `az keyvault secret set`

```bash
az keyvault secret set --vault-name kv-lab -n MiSecreto --value "valor"
```

| Largo | Corto |
|---|---|
| `--vault-name` | *(sin corto)* |
| `--name` | `-n` |
| `--value` | *(sin corto)* |

---

## `az cosmosdb`

```bash
az cosmosdb create -n cosmos-lab -g rg-lab
```

| Largo | Corto |
|---|---|
| `--name` | `-n` |
| `--resource-group` | `-g` |

---

## Tabla resumen — los que más vas a usar

| Flag corto | Significa | Aparece en |
|---|---|---|
| `-g` | `--resource-group` | Casi todos los comandos de recursos |
| `-n` | `--name` | Casi todos los comandos de recursos |
| `-l` | `--location` | `group create`, `keyvault create`, etc. |
| `-r` | `--registry` | Todos los `az acr *` |
| `-t` | `--image` | `az acr build`, `az acr repository show`, `az acr task create` |
| `-p` | `--plan` | `az webapp create` |
| `-o` | `--output` | Cualquier comando (table/json/tsv) |

---

## ⚠️ Errores comunes con flags cortos (ya los viviste en la práctica)

1. **`--t` no existe** — el corto de `--image` en `acr build` es `-t` (una sola letra), no `--t`
2. **No todos los flags tienen versión corta** — `--cmd`, `--schedule`, `--sku`, `--settings` casi siempre van completos
3. **El mismo corto puede significar cosas distintas** según el comando (ej: `-s` a veces es `--subscription`, a veces `--sku` en otros contextos) — si tienes duda, usa `az <comando> --help` para confirmar

---

## Cómo verificar los cortos de cualquier comando tú mismo

```bash
az acr task create --help
```

Esto lista todos los parámetros — los que tienen forma corta la muestran junto al nombre largo, ej:

```
--name -n [Required] : The name of the task.
```
