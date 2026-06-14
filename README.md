secure-azure-network/
├── .github/
│   └── workflows/
│       └── terraform-ci.yml
├── modules/
│   ├── network/          # VNets, subnets, peering
│   ├── security/         # NSGs and rules
│   ├── routing/          # route tables
│   └── vpn/              # VPN gateway
├── environments/
│   └── dev/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── terraform.tfvars.example
├── diagrams/
│   └── architecture.png
├── scripts/
│   ├── deploy.sh
│   └── teardown.sh
├── .gitignore            cat > .gitignore << 'EOF'
# Terraform state — NEVER commit (contains secrets, IPs, resource IDs)
*.tfstate
*.tfstate.*
*.tfstate.backup

# Terraform working directory and plugins
.terraform/
.terraform.lock.hcl.backup

# Plan output files
*.tfplan
tfplan

# Real variable files — may contain secrets. Commit only the .example
terraform.tfvars
*.auto.tfvars
secrets.auto.tfvars

# Crash logs
crash.log
crash.*.log

# CLI config / credentials
.terraformrc
terraform.rc
EOF
├── .tfsec.yml            # optional config
└── README.md
