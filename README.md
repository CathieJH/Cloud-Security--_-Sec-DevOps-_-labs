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
├── .gitignore
├── .tfsec.yml            # optional config
└── README.md
