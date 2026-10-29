# Lab 01 — Azure Networking

A hands-on lab using Azure CLI and Bash to create a virtual network,
three subnets, and Network Security Groups.

## Infrastructure

- Resource group: `rg-lab01-networking`
- Region: `austriaeast`
- VNet: `lab01-vnet` — `10.0.0.0/16`

| Subnet | Address range |
|---|---|
| subnet-frontend | 10.0.1.0/24 |
| subnet-backend | 10.0.2.0/24 |
| subnet-database | 10.0.3.0/24 |

Each subnet has an associated NSG for configuring traffic rules.

## Run

Prerequisites: Bash, Azure CLI, and an active Azure subscription.
Sign in and select the intended subscription before running:

```bash
bash commands.sh
```

## Clean up

Deletes the lab resource group and everything inside it:

```bash
bash cleanup.sh
```

The automatically created `NetworkWatcherRG` is separate.

## What I learned

- Resource groups, VNets, subnets, and CIDR ranges
- Creating and associating NSGs
- Rule sources, ports, directions, and priorities
- Azure CLI authentication and regional restrictions
- Creating and removing infrastructure with Bash

## Limitations

This lab configures networking only; no applications or VMs are deployed.
Custom allow rules alone do not enforce isolation between tiers because
Azure's default rules allow traffic within the VNet.

## Reference

Based on:
https://github.com/mzazon/cloud-projects/blob/main/azure/basic-network-setup-vnet-subnets/basic-network-setup-vnet-subnets.md