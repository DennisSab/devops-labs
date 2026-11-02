#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/config.sh"

echo "Deleting $RESOURCE_GROUP and all resources inside it..."

az group delete --name "$RESOURCE_GROUP"

echo "Resource group deletion completed."