# Secure Azure Network (Terraform)

![Terraform CI](https://github.com/<your-username>/secure-azure-network/actions/workflows/terraform-ci.yml/badge.svg)

A hub-and-spoke Azure network built with Terraform, designed around a
least-privilege, default-deny security model. Provisions VNets, subnets,
NSGs, route tables and an Entra ID–authenticated VPN gateway, with a
GitHub Actions pipeline that validates the code and runs two security
scanners (Checkov and Trivy) on every pull request.

## Architecture

![Architecture diagram](diagrams/architecture.png)

A central **hub** VNet hosts the VPN gateway and shared services. Two
**spoke** VNets — an application tier and a data tier — are peered to the
hub. Traffic between spokes is routed through the hub for inspection, and
the data tier is never reachable from the internet.

| Network            | CIDR          | Purpose                              |
|--------------------|---------------|--------------------------------------|
| Hub VNet           | 10.0.0.0/16   | VPN gateway, shared services         |
| └ GatewaySubnet    | 10.0.0.0/24   | VPN gateway (Azure-required name)     |
| └ Shared services  | 10.0.1.0/24   | Future firewall / jump host           |
| App spoke VNet     | 10.1.0.0/16   | Application tier                      |
| └ App subnet       | 10.1.0.0/24   | App workloads                         |
| Data spoke VNet    | 10.2.0.0/16   | Data tier                             |
| └ Data subnet      | 10.2.0.0/24   | Databases — no internet exposure      |

## Design decisions

**Hub-and-spoke topology.** The canonical enterprise Azure pattern. It
centralises shared services (VPN, future firewall) in the hub and isolates
workloads into independently governed spokes, so blast radius is contained
and routing/inspection is centralised.

**Default-deny segmentation.** Each subnet has an NSG with explicit allow
rules above an explicit deny-all rule. The data tier accepts traffic *only*
from the app subnet, on a single port, and explicitly denies all inbound
internet traffic. Nothing is reachable unless a rule permits it.

**Routing through the hub.** User-defined routes force inter-spoke traffic
through the hub rather than via direct peering, which is where a firewall /
NVA would inspect it. The next-hop is parameterised so a firewall can be
dropped in without changing the spoke configuration.

**Entra ID–authenticated VPN.** The point-to-site gateway uses Microsoft
Entra ID for authentication, so VPN access is governed by the same identity
platform (and, in a real tenant, the same Conditional Access policies) as
the rest of the estate — rather than by static certificates or keys.

## Security controls mapping

| Control area          | Implementation                          | Framework reference        |
|-----------------------|-----------------------------------------|----------------------------|
| Network segmentation  | Hub-and-spoke + per-subnet NSGs         | ISO 27001 A.8.20 / A.8.22  |
| Least-privilege access| Default-deny NSGs, single-port allows   | NIST SP 800-53 AC-4, SC-7  |
| Secure remote access  | Entra ID–authenticated P2S VPN          | ISO 27001 A.8.20; NIST AC-17|
| Configuration scanning| Checkov + Trivy in CI on every PR       | NIST SP 800-53 RA-5, CM-6  |
| Consistent governance | Mandatory tagging on all resources      | ISO 27001 A.5.9 (asset mgmt)|

*(Mappings are indicative, to show controls-thinking — not a formal audit.)*

## Repository layout

```
modules/network   VNets, subnets, peering
modules/security  NSGs and least-privilege rules
modules/routing   User-defined routes through the hub
modules/vpn       VPN gateway (P2S, with S2S documented)
environments/dev  Composition of the modules
scripts/          deploy.sh / teardown.sh
.github/workflows CI pipeline (fmt, validate, Checkov, Trivy)
```

## Deploy

```bash
cp environments/dev/terraform.tfvars.example environments/dev/terraform.tfvars
# edit terraform.tfvars with your Entra tenant details
az login
./scripts/deploy.sh
```

## Tear down

```bash
./scripts/teardown.sh
```

> **Cost note.** This is a deploy-on-demand lab, not a standing environment.
> The VPN gateway bills hourly even when idle (~£20–30/day for VpnGw1).
> Deploy it, capture evidence, then tear it down.

## Security note

`terraform.tfvars` and all state files are gitignored. State is never
committed (it can contain secrets and infrastructure detail). For a
production setup, state would live in an encrypted remote backend (Azure
Storage with locking), and CI would authenticate to Azure via OIDC
federation rather than stored secrets.

## What I'd build next

- Azure Firewall in the hub as the real inter-spoke next-hop
- Azure Bastion for management access (no public IPs on workloads)
- Private Endpoints for the data tier (keep PaaS traffic off the internet)
- Remote state backend with locking + OIDC-based CI authentication
- Microsoft Sentinel for flow-log monitoring and alerting
```
