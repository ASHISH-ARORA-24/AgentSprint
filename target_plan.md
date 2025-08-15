
# Target Plan

## 0. Foundations (Naming, Access, Repo)

### 0.1 Decide Client Code & Region

- **Client code:** `abc` (use per-client)
- **Region:** Central India (keep everything same region)

### 0.2 Naming & Tags

- **Resource Groups:** `rg-abc-net`, `rg-abc-core`, `rg-abc-runner`
- **VNet:** `vnet-abc`
- **Subnets:**
	- `subnet-rns` `10.0.2.0/26`
	- `subnet-runners` `10.0.1.0/24`
	- `subnet-jump` `10.0.3.0/28`
- **NSGs:** `nsg-abc-rns`, `nsg-abc-runners`, `nsg-abc-jump`
- **Tags (every resource):**
	- `project=RNS`
	- `client=abc`
	- `env=dev`
	- `owner=<you>`

### 0.3 Access/RBAC Setup

- Your admin account: Owner or Contributor at subscription/RG.
- Create two Entra groups: `rns-ops`, `rns-viewers`.
- Assign:
	- `rns-ops` = Contributor on `rg-abc-*`
	- `rns-viewers` = Reader

### 0.4 Git Repos

- **Repo A (IaC):** `/iac` (Terraform or Bicep)
- **Repo B (Functions + RNS stubs):** `/rns-system`
- Setup CI for `terraform fmt/validate/plan` on PR.

**Milestone:** Foundations done ✅

---

## 1. Networking & Security (Portal or IaC)

### 1.1 Resource Groups

- Create `rg-abc-net`, `rg-abc-core`, `rg-abc-runner`

### 1.2 VNet + Subnets (`10.0.0.0/16`)

- `vnet-abc`
- `subnet-runners` `10.0.1.0/24`
- `subnet-rns` `10.0.2.0/26`
- `subnet-jump` `10.0.3.0/28`

### 1.3 NSGs & Rules

- **runners (`nsg-abc-runners`)** → attach to `subnet-runners`
	- Inbound: Deny VirtualNetwork→VirtualNetwork, priority 100.
	- Outbound: allow to `10.0.2.0/26` (80/443), allow to internet (default).
- **rns (`nsg-abc-rns`)** → attach to `subnet-rns`
	- Inbound: allow from `10.0.1.0/24` (80/443), p=100.
	- Inbound: allow from `10.0.3.0/28` (22), p=110.
	- Inbound: explicit Deny all, p=200.
- **jump (`nsg-abc-jump`)** → attach to `subnet-jump`
	- Inbound: allow TCP 22 from your public IP/32, p=100.
	- Inbound: deny all, p=200.

### 1.4 Static Public IP (for NAT reuse)

- Create `pip-abc-nat` (Standard, Static). (Keep forever; cheap; preserves allowlists.)

**Milestone:** VNet/NSGs/PIP online; Effective rules look correct ✅

---

## 2. Core PaaS (Queues, Vault) + Identities

### 2.1 Storage Account (`rg-abc-core`)

- **Queues:** `gh-webhooks`, `evictions`
- **Blobs:** `logs/` (for cheap JSON logs)
- SAS disabled; use Managed Identity (MI) later.

### 2.2 Key Vault (`rg-abc-core`)

- **Secrets to add (placeholders now if needed):**
	- `GH_APP_ID`
	- `GH_INSTALLATION_ID`
	- `GH_PRIVATE_KEY` (PEM)
	- `GH_WEBHOOK_SECRET`
- Enable Soft delete & Purge protection.

### 2.3 Managed Identities

- Will use System-assigned MI on:
	- Function App (later)
	- RNS VM (later)

### 2.4 RBAC (least privilege)

- **Functions MI:**
	- KV: Key Vault Secrets User
	- Storage Queue: Storage Queue Data Contributor (webhook sends; idle/tokens may peek/recv)
	- Compute: custom role or Virtual Machine Contributor on `rg-abc-core` (start/deallocate RNS)
	- Network: Network Contributor on `rg-abc-net` (create/delete NAT, subnet update)
- **RNS VM MI:**
	- KV: Key Vault Secrets User
	- Storage Queue: Storage Queue Data Contributor (recv/process webhooks)
	- (Later) Compute on `rg-abc-runner` for creating runner VMs

**Milestone:** Storage + KV up, permissions mapped (even if MI not yet created) ✅

---

## 3. Function App (Webhook + Orchestrations)

### 3.1 Create Function App (Consumption, Linux)

- **Name:** `func-abc` in `rg-abc-core`
- Enable System-assigned MI.
- Add App Settings:
	- `QUEUE_NAME=gh-webhooks`
	- `IDLE_MINUTES=30`
	- `RNS_VM_RG=rg-abc-core`
	- `RNS_VM_NAME=vm-abc-rns`
	- `VNET_RG=rg-abc-net`
	- `VNET_NAME=vnet-abc`
	- `RUNNERS_SUBNET=subnet-runners`
	- `NAT_NAME=natg-abc`
	- `STATIC_PIP_NAME=pip-abc-nat`
	- (KV references for GH secrets if you prefer)

### 3.2 Functions to Deploy (initial stubs OK)

- `webhook_github` (HTTP trigger): verify HMAC (use `GH_WEBHOOK_SECRET`) → enqueue payload → start Durable orchestration `EnsureInfra(abc)` (fixed instance ID) → return 202.
- `EnsureInfra` (Durable orchestrator + activities): stub now (log only).
- `idle_killer` (Timer): stub (log only).

### 3.3 Security on Function

- Use Function key for now. (Later: restrict inbound to GitHub IPs; still optional on Consumption.)
- HTTPS enforced (default).

**Milestone:** Function URL live; test HTTP 200; can write to queue ✅

---

## 4. RNS Host VM (skeleton only)

### 4.1 Create RNS VM (`rg-abc-core`)

- Size: start with B1ms; no public IP; NIC in `subnet-rns`
- System-assigned MI enabled.
- (If size supports) Ephemeral OS disk enabled.

### 4.2 Bootstrap (cloud-init or SSH via temporary jump)

- Install Python 3.11, uvicorn, fastapi, Azure SDKs, azure-storage-queue.
- Create a minimal FastAPI app with `/healthz` returning 200.
- Create a queue consumer service that pulls `gh-webhooks` and writes logs to `/var/log/rns-queue.log`.
- systemd units: `rns-api.service`, `rns-worker.service`

### 4.3 Connectivity Test

- Manually create a temporary jump host (or assign temp PIP) → SSH into RNS; confirm `/healthz` and queue pull.

**Milestone:** RNS VM reachable privately; worker can read queue ✅

---

## 5. End-to-End “Walking Skeleton”

### 5.1 Wire GitHub → Function

- In your GitHub App (or repo webhook), set `https://<func-abc>.azurewebsites.net/api/webhook_github`
- Add `GH_WEBHOOK_SECRET` to Key Vault; Function reads it.

### 5.2 Send a Test Webhook

- Expect: Function 202 → Queue receives message → RNS worker logs it.

**Milestone:** First end-to-end event flows successfully ✅

---

## 6. Sleep/Wake Automation (Always-Hibernation)

### 6.1 Implement EnsureInfra Activities (real)

- `create_or_attach_nat`:
	- If `natg-abc` missing → create (attach `pip-abc-nat`)
	- Associate to `subnet-runners`
- `start_rns_vm_if_needed`:
	- If `vm-abc-rns` powerState != running → Start
- Optional: `wait_rns_ready`: poll VM instanceView or call `http://rns:80/healthz` (if reachable) with backoff.

### 6.2 Make HTTP Webhook Do Enqueue First, Then EnsureInfra

- Guarantees no webhook is lost during wake.

### 6.3 Implement idle_killer (Timer Function, every 5–10 min)

- If `gh-webhooks` length == 0 and last_activity ≥ 30m:
	- Deallocate RNS VM
	- Detach NAT (update subnet) and Delete `natg-abc` (keep `pip-abc-nat`)

### 6.4 Race Safety

- Durable instance ID: fixed per client (e.g., `ensure-rns-abc`) → platform guarantees single instance.
- (Alternative: blob lease lock `rns-start-lock`)

### 6.5 Test Cold Path

- Manually deallocate RNS + delete NAT.
- Trigger webhook: verify NAT created, associated; RNS started; message processed.

**Milestone:** Always-hibernation flow works reliably ✅

---

## 7. Jump Host (On-Demand)

### 7.1 Function: jump_broker (HTTP + Durable)

- **Input:** `sourceIp`, `ttlMinutes=30`
- **Create:** Standard PIP, NIC in `subnet-jump`, small VM B1s with cloud-init (SSH key), NSG rule allow 22 from `sourceIp/32`
- **Return:** public IP
- **Orchestrator:** wait `ttlMinutes` → delete VM → delete NIC & PIP → remove temp NSG rule

### 7.2 Test

- Call function → SSH in → confirm TTL deletion

**Milestone:** Ephemeral jump works ✅

---

## 8. Token Broker & Eviction Receiver (Glue)

### 8.1 Function: runner_token_broker (HTTP)

- **Auth:** Managed Identity from VM callers (validate IMDS token, objectId, and subnet)
- **Logic:** create GitHub runner registration token via GitHub App creds (from KV)
- **Response:** `{ token, expires_at }` (short-lived)

### 8.2 Function: eviction_receiver (HTTP)

- Runners call on eviction → enqueue message `evictions` → (later) RNS handles replacement

**Milestone:** Both glue endpoints respond and log ✅

---

## 9. Images & Runners (Prepare; minimal now)

### 9.1 Azure Compute Gallery

- **Gallery:** `sig-abc`
- **Image definition:** `img-runner-ubuntu`
- (Version later with Packer/GitHub Actions when you bake the runner image.)

### 9.2 (Optional now) VMSS Skeleton

- Create VMSS (Spot) in `subnet-runners` (disabled by default)
- RNS will eventually use SDK to scale instances per job queue

**Milestone:** Image gallery online; runner base path ready ✅

---

## 10. Policies, Alerts, Cost

### 10.1 Azure Policy (at RG or Subscription level)

- Deny public IPs on NICs in `rg-abc-runner`
- Require Managed Identity on all compute
- Allowed images: only your SIG for runner VMs
- Require tags (`client`, `env`, `owner`)

### 10.2 Budget & Alerts

- Monthly budget for `client=abc`
- Alerts: Function failures (5xx), queue backlog, NAT attach errors, VM start failures, DLQ > 0

### 10.3 Logging (low-cost)

- App/Function logs → Blob (structured JSON)
- Keep 7–30 days rolling

**Milestone:** Guardrails in place; alerts wired ✅

---

## 11. Go/No-Go Checklist (Pre-RNS Code)