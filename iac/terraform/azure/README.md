# Resource Group Allocation

This project uses three main resource groups for organizing Azure resources:

| Resource Group         | Purpose/Resources Placed Here                |
|-----------------------|----------------------------------------------|
| rg-<client_code>-net  | Networking resources: VNet, subnets, NSGs, jump host, public IPs |
| rg-<client_code>-core | Core services: Storage Account, Key Vault, Function Apps, Agent Sprint VM |
| rg-<client_code>-agent| Agent VMs, VMSS, Compute Gallery, agent-related infrastructure |

**Jump Host:**
- The jump host should be created in `rg-<client_code>-net` as it is a network-related resource and may require access to subnets, NSGs, and public IPs.

This structure keeps networking, core services, and agent infrastructure cleanly separated for easier management and access control.
# Terraform Infrastructure

This folder contains Terraform code for provisioning Azure resources for AgentSprint.

- All .tf files here are for Azure.
- Use this folder for all Terraform modules, variables, and state files.
- For other IaC tools, use sibling folders in `/iac`.
