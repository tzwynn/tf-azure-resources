# Azure Infrastructure with Terraform (AZ-104 Practice)

## Overview

This project provisions core Azure infrastructure using **Terraform** as part of my preparation for the **AZ-104: Microsoft Azure Administrator** certification.

While studying Azure services, I am leveraging my existing Terraform knowledge to:

- Understand how Azure resources behave
- Compare Azure concepts with AWS equivalents
- Practice Infrastructure as Code (IaC)
- Build hands-on experience beyond the Azure Portal

This repository is an evolving lab environment and will be expanded over time with variables, modules, outputs, and data sources.

---

## Learning Objectives

- Understand Azure core services (Resource Groups, VNet, Subnet, NSG, VM, Storage)
- Map Azure concepts to AWS equivalents
- Deploy infrastructure using Terraform
- Validate networking and security behavior
- Prepare for AZ-104 exam objectives

---

## Architecture

This configuration provisions:

- Resource Group
- Virtual Network (VNet)
- Subnet
- Public IP (Static)
- Network Interface (NIC)
- Network Security Group (NSG) with SSH restriction
- Linux Virtual Machine (Ubuntu 24.04 LTS Minimal)
- Storage Account
- Blob Container

---

## Azure vs AWS Concept Mapping

| Azure | AWS Equivalent |
|--------|----------------|
| Resource Group | Logical grouping (no direct AWS equivalent) |
| Virtual Network (VNet) | VPC |
| Subnet | Subnet |
| Network Security Group (NSG) | Security Group |
| Public IP | Elastic IP |
| Network Interface (NIC) | ENI |
| Storage Account | Storage namespace |
| Blob Container | S3 Bucket |
| Linux Virtual Machine | EC2 Instance |

---

## Resources Created

### Virtual Machine
- OS: Ubuntu 24.04 LTS (Minimal)
- Size: Standard_D2ads_v7
- Authentication: SSH key
- Public IP: Static
- NSG rule: SSH allowed only from specific IP

### Networking
- VNet: 10.0.0.0/16
- Subnet: 10.0.2.0/24
- NSG: Inbound SSH allowed from a single IP

### Storage
- Storage Account (Standard_LRS)
- Blob Container (Blob-level public access)

---

## How to Deploy

### Prerequisites

- Terraform installed (>= 1.5 recommended)
- Azure CLI installed
- Logged in to Azure:

```bash
az login