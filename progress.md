# Progress Update (August 15, 2025)

- Created `clients/` folder for client-specific Terraform variable files
- Added example `abc.tfvars` for client configuration
- Updated root `README.md` to document usage of tfvars and correct relative path
- Verified Terraform workflow: init, plan, apply with service principal authentication
- Resource groups successfully created in Azure
# Progress Tracker

This file tracks the progress of tasks from the target plan. Update this file as you complete steps or add notes, blockers, and references to images.

## How to Use
- Mark tasks as started, in progress, or completed.
- Add notes, blockers, and next steps for each item.
- Reference images from the `images/` folder using `![description](images/filename.png)`.

---

## Progress Log


*Start logging your progress below:*

  - Used for client 'abc' and project 'AgentSprint'
  - Scope: /subscriptions/<subscription_id>
  - Credentials stored for Terraform authentication ([see details](initial_setup/azure.md))

---

**August 18, 2025:**
  - Refactored NSG rules for agents to use separate outbound rules for HTTP (80) and HTTPS (443) ports, following Azure requirements.
  - Updated Terraform code to reference subnet address prefix dynamically.
  - Fixed NSG name interpolation to use `${var.client_code}`.
  - Successfully deployed NSG for agents with correct outbound and inbound rules using `deploy.sh`.
  - Validated deployment: resources created as expected, no errors.

**August 19, 2025:**
  - Created static public IP (`pip-abc-nat`) in Azure using Terraform as per target plan.
  - Verified resource group assignment and configuration.
  - Deployment script ran successfully, resource provisioned and validated.
---

## Checklist vs Target Plan (as of August 18, 2025)

### 0. Foundations
- [x] Client code and region decided (`abc`, Central India)
- [x] Naming conventions and tags defined
- [x] Resource group names, VNet, subnets, and NSGs named
- [x] Git repo structure set up for IaC (`/iac`), Azure-specific Terraform under `/iac/terraform/azure`
- [x] .gitignore updated for Terraform and repo hygiene
- [x] README and documentation updated
- [x] Milestone: Foundations done ✅

### 1. Networking & Security
- [x] Resource groups created: `rg-abc-net`, `rg-abc-core`, `rg-abc-runner`
- [x] VNet and subnets defined in Terraform: `vnet-abc`, `subnet-agents`, `subnet-agt`, `subnet-jump`
- [x] NSGs defined and attached to subnets: `nsg-abc-agents`, `nsg-abc-agt`, `nsg-abc-jump`
- [x] Milestone: VNet/NSGs online; rules defined in code ✅

### 0.3 Access/RBAC Setup
- [x] Service principal created for Terraform authentication
- [x] Admin account and RBAC setup documented (Entra groups creation pending)

### 0.4 Git Repos
- [x] IaC repo structure and automation scripts created
- [ ] CI setup for Terraform formatting/validation (pending)

### Other Progress
- [x] Deployment script (`deploy.sh`) works and provisions resources as per Terraform code
- [x] Manual edits and commits pushed to GitHub

---

### Pending/Next Steps
- [ ] Static Public IP for NAT (`pip-abc-nat`)
- [ ] Storage Account, Key Vault, Managed Identities, and RBAC for PaaS (Section 2)
- [ ] Function App and orchestrations (Section 3)
- [ ] AGT Host VM and connectivity (Section 4)
- [ ] End-to-end event flow (Section 5)
- [ ] Sleep/Wake automation, jump host, token broker, eviction receiver, images, policies, alerts, and logging (Sections 6–10)
