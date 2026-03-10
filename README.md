# Azure VM Snapshot Automation (Multi-Subscription)

This automation script creates snapshots for Azure Virtual Machines across multiple subscriptions using tags.

It is designed to run inside an **Azure Automation Runbook** using **Managed Identity**.

## Features

- Snapshot OS disks
- Snapshot data disks
- Works across multiple subscriptions
- Tag-based VM selection
- Designed for Azure Automation Runbooks

---

## Tag Requirement

Add the following tag to any VM that requires a snapshot:

Key:
Snapshot

Value:
Yes

---

## Prerequisites

1. Azure Automation Account
2. System Assigned Managed Identity enabled
3. Role assignment:

Contributor  
or  

Disk Snapshot Contributor

Assigned at subscription/RG or Resource level.

---

## How It Works

1. Runbook authenticates using Managed Identity
2. Loops through subscriptions
3. Finds tagged VMs
4. Creates snapshots for OS and data disks

---

## Example Use Cases

- Pre-maintenance snapshots
- Upgrade rollback protection
- Patch management
- Disaster recovery preparation

---

## Runbook Script

The script is available here:

runbook/snapshot-vm-multisubscription.ps1

---

## Video Walkthrough

A full demo of this automation is available on my YouTube channel:

CloudWithAarya

#azure #azureautomation #cloudautomation #devops #powershell
