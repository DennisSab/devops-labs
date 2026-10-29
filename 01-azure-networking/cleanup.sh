#!/usr/bin/env bash
set -euo pipefail

RESOURCE_GROUP="rg-lab01-networking"

# Delete the lab resource group and everything inside it
az group delete \
  --name "$RESOURCE_GROUP" \
  --yes \
  --no-wait

echo "Deletion started for: $RESOURCE_GROUP"