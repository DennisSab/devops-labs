# Create a resource group for lab 01
az group create \
  --name rg-lab01-networking \
  --location austriaeast \
  --tags project=devops-labs lab=01 environment=learning \
  --output table

az network vnet create \
    --resource-group rg-lab01-networking \
    --name lab01-vnet \
    --address-prefix 10.0.0.0/16 \
    --location austriaeast \
    --output table

az network vnet subnet create \
    --resource-group rg-lab01-networking \
    --vnet-name lab01-vnet \
    --name subnet-frontend \
    --address-prefix 10.0.1.0/24 \
    --output table


az network vnet subnet create \
    --resource-group rg-lab01-networking \
    --vnet-name lab01-vnet \
    --name subnet-backend \
    --address-prefix 10.0.2.0/24 \
    --output table


az network vnet subnet create \
    --resource-group rg-lab01-networking \
    --vnet-name lab01-vnet \
    --name subnet-database \
    --address-prefix 10.0.3.0/24 \
    --output table


az network nsg create \
    --resource-group rg-lab01-networking \
    --name nsg-frontend \
    --location austriaeast \
    --tags project=devops-labs lab=01 environment=learning tier=frontend \
    --output table

az network nsg rule create \
    --resource-group rg-lab01-networking \
    --nsg-name nsg-frontend \
    --name allow-http \
    --priority 1000 \
    --access Allow \
    --protocol Tcp \
    --direction Inbound \
    --source-address-prefixes '*' \
    --destination-port-ranges 80 \
    --output table


az network nsg create \
    --resource-group rg-lab01-networking \
    --name nsg-backend \
    --location austriaeast \
    --tags project=devops-labs lab=01 environment=learning tier=backend \
    --output table

az network nsg rule create \
    --resource-group rg-lab01-networking \
    --nsg-name nsg-backend \
    --name allow-from-frontend \
    --priority 1000 \
    --access Allow \
    --protocol Tcp \
    --direction Inbound \
    --source-address-prefixes 10.0.1.0/24 \
    --destination-port-ranges 8080 \
    --output table

az network nsg create \
    --resource-group rg-lab01-networking \
    --name nsg-database \
    --location austriaeast \
    --tags project=devops-labs lab=01 environment=learning tier=database \
    --output table

az network nsg rule create \
    --resource-group rg-lab01-networking \
    --nsg-name nsg-database \
    --name allow-from-backend \
    --priority 1000 \
    --access Allow \
    --protocol Tcp \
    --direction Inbound \
    --source-address-prefixes "10.0.2.0/24" \
    --destination-port-ranges 5432 \
    --output table

#associate NSGs with subnets
az network vnet subnet update \
    --resource-group rg-lab01-networking \
    --vnet-name lab01-vnet \
    --name subnet-frontend \
    --network-security-group nsg-frontend \
    --output table  

az network vnet subnet update \
    --resource-group rg-lab01-networking \
    --vnet-name lab01-vnet \
    --name subnet-backend \
    --network-security-group nsg-backend \
    --output table  

az network vnet subnet update \
    --resource-group rg-lab01-networking \
    --vnet-name lab01-vnet \
    --name subnet-database \
    --network-security-group nsg-database \
    --output table


