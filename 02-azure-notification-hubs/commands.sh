#!/usr/bin/env bash
set -euo pipefail

# Load the lab configuration
source "$(dirname "${BASH_SOURCE[0]}")/config.sh"

# Get the currently selected subscription
SUBSCRIPTION_ID=$(az account show --query id --output tsv)

# Check required configuration
: "${RESOURCE_GROUP:?Missing RESOURCE_GROUP in config.sh}"
: "${LOCATION:?Missing LOCATION in config.sh}"
: "${NH_NAMESPACE:?Missing NH_NAMESPACE in config.sh}"
: "${NH_LOCATION:?Missing NH_LOCATION in config.sh}"

# This lab uses Germany West Central
if [[ "$NH_LOCATION" != "germanywestcentral" ]]; then
    echo "Stop: set NH_LOCATION=\"germanywestcentral\" in config.sh."
    exit 1
fi

# Display the deployment target
printf 'Subscription: %s\nResource group: %s\nNamespace: %s\nRegion: %s\n' \
    "$SUBSCRIPTION_ID" \
    "$RESOURCE_GROUP" \
    "$NH_NAMESPACE" \
    "$NH_LOCATION"

# Create or update the resource group
az group create \
    --name "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --tags purpose=notifications environment=demo \
    --output table

# Namespace management API address
NAMESPACE_URL="https://management.azure.com/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.NotificationHubs/namespaces/${NH_NAMESPACE}?api-version=2023-09-01"

# Create namespace
echo "Creating namespace (PUT)..."

az rest \
    --method put \
    --url "$NAMESPACE_URL" \
    --headers "Content-Type=application/json" \
    --body "{
      \"location\": \"${NH_LOCATION}\",
      \"sku\": {
        \"name\": \"Free\"
      },
      \"properties\": {
        \"zoneRedundancy\": \"Disabled\",
        \"replicationRegion\": \"None\"
      }
    }"

# Read the settings Azure applied
echo "Checking namespace (GET)..."

az rest \
    --method get \
    --url "$NAMESPACE_URL" \
    --query "{Region:location,SKU:sku.name,Zones:properties.zoneRedundancy,Replication:properties.replicationRegion,State:properties.provisioningState}" \
    --output table


source ./config.sh

az notification-hub create \
    --resource-group "$RESOURCE_GROUP" \
    --namespace-name "$NH_NAMESPACE" \
    --name "$NH_NAME" \
    --location "$NH_LOCATION" \
    --output table


# Retrieve the Listen connection string
LISTEN_CONNECTION=$(az notification-hub authorization-rule list-keys \
    --resource-group "$RESOURCE_GROUP" \
    --namespace-name "$NH_NAMESPACE" \
    --notification-hub-name "$NH_NAME" \
    --name "DefaultListenSharedAccessSignature" \
    --query primaryConnectionString \
    --output tsv)

echo "✅ Retrieved Listen connection string"


# Retrieve the Full Access connection string
FULL_CONNECTION=$(az notification-hub authorization-rule list-keys \
    --resource-group "$RESOURCE_GROUP" \
    --namespace-name "$NH_NAMESPACE" \
    --notification-hub-name "$NH_NAME" \
    --name "DefaultFullSharedAccessSignature" \
    --query primaryConnectionString \
    --output tsv)

if [[ -n "$FULL_CONNECTION" ]]; then
    echo "✅ Full Access connection string retrieved"
else
    echo "❌ Full Access connection string retrieval failed"
    exit 1
fi


# Verify that the hub exists
az notification-hub show \
    --resource-group "$RESOURCE_GROUP" \
    --namespace-name "$NH_NAMESPACE" \
    --name "$NH_NAME" \
    --query "{Name:name,Location:location}" \
    --output table

# Display authorization policies and their permissions
az notification-hub authorization-rule list \
    --resource-group "$RESOURCE_GROUP" \
    --namespace-name "$NH_NAMESPACE" \
    --notification-hub-name "$NH_NAME" \
    --output json

# Validate Listen connection string retrieval
LISTEN_CONNECTION=$(az notification-hub authorization-rule list-keys \
    --resource-group "$RESOURCE_GROUP" \
    --namespace-name "$NH_NAMESPACE" \
    --notification-hub-name "$NH_NAME" \
    --name "DefaultListenSharedAccessSignature" \
    --query primaryConnectionString \
    --output tsv)

if [[ -n "$LISTEN_CONNECTION" ]]; then
    echo "✅ Listen connection string retrieved"
else
    echo "❌ Listen connection string retrieval failed"
    exit 1
fi

# Verify resource group configuration
az group show \
    --name "$RESOURCE_GROUP" \
    --query "{Name:name,Location:location,Tags:tags}" \
    --output json

# Verify namespace configuration, including paid optional features
az rest \
    --method get \
    --url "$NAMESPACE_URL" \
    --query "{Name:name,Region:location,SKU:sku.name,Zones:properties.zoneRedundancy,Replication:properties.replicationRegion,State:properties.provisioningState}" \
    --output table