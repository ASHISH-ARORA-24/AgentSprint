# Azure Service Principal Setup for Terraform

## 1. Log in to Azure

```bash
az login
```
- This opens a browser window for authentication.

## 2. Create a Service Principal

Replace `<name>` with a unique name and `<subscription_id>` with your Azure subscription ID:

```bash
az ad sp create-for-rbac --name <name> --role Contributor --scopes /subscriptions/<subscription_id>
```
- This will output:
  - `appId` (Client ID)
  - `password` (Client Secret)
  - `tenant` (Tenant ID)
  - `subscriptionId`

## 3. Set Environment Variables for Terraform

Copy the output values and set them in your shell:

```bash
export ARM_CLIENT_ID="<appId>"
export ARM_CLIENT_SECRET="<password>"
export ARM_SUBSCRIPTION_ID="<subscriptionId>"
export ARM_TENANT_ID="<tenant>"
```

Terraform will use these credentials to authenticate with Azure.

---

*Refer to this file for step-by-step Azure authentication and service principal setup for Terraform.*
az ad sp create-for-rbac --name sp-abc-agentsprint-terraform --role Contributor --scopes /subscriptions/e0024e16-2be5-4d15-acfd-43f953a7d83b