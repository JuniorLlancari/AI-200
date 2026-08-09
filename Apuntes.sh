az appservice list-locations --sku B1 
az vm list-usage --location canadacentral  -o table
az webapp config show -n docprocessor-lab-001 -g rg-appservice-lab --query "acrUseManagedIdentityCreds"
az group delete --name rg-appservice-lab --yes --no-wait
az role assignment create --assignee-object-id $principalIdStaging --assignee-principal-type ServicePrincipal --scope $acrId --role AcrPull
