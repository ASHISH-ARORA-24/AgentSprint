# Client-Specific Configuration

Client variables are managed in the `clients/` folder. Each client has a separate `.tfvars` file, e.g.:

```
clients/abc.tfvars
clients/xyz.tfvars
```

To deploy for a specific client, run Terraform from the `iac/terraform/azure` directory and use:
```bash
terraform apply -var-file="../../clients/abc.tfvars"
```

Update or add new `.tfvars` files in `clients/` for each client as needed.

# Quickstart: Azure & Terraform Commands

To deploy Azure infrastructure, use the following workflow (from `iac/terraform/azure`):

1. Export Azure service principal credentials:
	```bash
	export ARM_CLIENT_ID="<your-client-id>"
	export ARM_CLIENT_SECRET="<your-client-secret>"
	export ARM_SUBSCRIPTION_ID="<your-subscription-id>"
	export ARM_TENANT_ID="<your-tenant-id>"
	```

2. Login to Azure with service principal:
	```bash
	az login --service-principal -u "$ARM_CLIENT_ID" -p "$ARM_CLIENT_SECRET" --tenant "$ARM_TENANT_ID"
	```

3. Show current Azure account:
	```bash
	az account show
	```

4. Initialize Terraform:
	```bash
	terraform init
	```

5. Preview changes:
	```bash
	terraform plan -var-file="../../clients/abc.tfvars"
	```

6. Apply changes:
	```bash
	terraform apply -var-file="../../clients/abc.tfvars"
	```

This sequence ensures proper authentication and deployment of resources. Update credentials as needed for your environment.

# Multi-Cloud Structure

Terraform code for each cloud provider is organized in its own subfolder:

- `/iac/terraform/azure/` for Azure
- `/iac/terraform/aws/` for AWS (future)
- `/iac/terraform/gcp/` for GCP (future)

General documentation and onboarding remain at the root or in `/iac/terraform/`.

# Resource Group Overview (Azure)

This project organizes Azure resources into three main resource groups for clarity and maintainability:

| Resource Group         | Purpose/Resources Placed Here                |
|-----------------------|----------------------------------------------|
| rg-<client_code>-net  | Networking resources: VNet, subnets, NSGs, jump host, public IPs |
| rg-<client_code>-core | Core services: Storage Account, Key Vault, Function Apps, Agent Sprint VM |
| rg-<client_code>-agent| Agent VMs, VMSS, Compute Gallery, agent-related infrastructure |

**Jump Host:**
- The jump host should be created in `rg-<client_code>-net` as it is a network-related resource and may require access to subnets, NSGs, and public IPs.

This structure keeps networking, core services, and agent infrastructure cleanly separated for easier management and access control.

# AgentSprint
