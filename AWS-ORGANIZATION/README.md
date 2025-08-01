# AWS Organization with SSO and Service Control Policies

This project creates and manages an AWS Organization with multiple accounts, IAM Identity Center (SSO), and Service Control Policies using Terraform. It demonstrates centralized account management, cross-account access, and governance controls.

## Architecture Overview

The solution creates:
- **AWS Organization** with centralized management
- **Two AWS Accounts**: Production and Security
- **IAM Identity Center (SSO)** for centralized authentication
- **Service Control Policies (SCPs)** for governance
- **Cross-account access** with permission sets

## Project Structure

```
aws-organization/
├── aws-org-accounts/
│   ├── modules/
│   │   └── account/
│   │       ├── main.tf          # Account and OU creation logic
│   │       ├── variables.tf     # Module input variables
│   │       └── outputs.tf       # Module outputs (account IDs, OU IDs)
│   ├── prod/
│   │   ├── main.tf              # Production account resources
│   │   ├── variables.tf         # Prod-specific variables
│   │   ├── providers.tf         # AWS provider configuration
│   │   └── backend.tf           # Terraform backend configuration
│   ├── security/
│   │   ├── main.tf              # Security account resources
│   │   ├── variables.tf         # Security-specific variables
│   │   ├── providers.tf         # AWS provider configuration
│   │   └── backend.tf           # Terraform backend configuration
│   ├── main.tf                  # Organization, SSO, and account creation
│   ├── variables.tf             # Global variables
│   ├── outputs.tf               # Account IDs and SSO portal URL
│   ├── providers.tf             # AWS provider with version constraints
│   ├── backend.tf               # S3 backend configuration
│   ├── terraform.tfvars.example # Example variable values
│   └── .gitignore               # Git ignore patterns
└── README.md                    # This file
```
NB: Terraform config for respective accounts to provision resources is not included in this repo but you can add this by looking at the project structure above.

## Features

### 🏢 **Organization Management**
- Creates AWS Organization with full feature set
- Organizational Units (OUs) for logical grouping
- Centralized billing and management

### 🔐 **IAM Identity Center (SSO)**
- Centralized user authentication
- Permission sets with different access levels
- Cross-account access without IAM users
- Session duration controls (1-12 hours)

### 📋 **Service Control Policies**
- Preventive guardrails for accounts
- Restricts expensive services (SageMaker, Redshift, EMR)
- Applied at OU level for inheritance

### 🔄 **Cross-Account Access**
- Security team can access both accounts
- Admin access to Security account
- Read-only access to Production account

## Prerequisites

1. **Terraform** >= 1.0 installed
2. **AWS CLI** configured with appropriate credentials
3. **AWS Account** with Organizations permissions
4. **S3 bucket** for Terraform state (optional but recommended)

## Required AWS Permissions

Your AWS user/role needs:
- `OrganizationsFullAccess`
- `AWSSSOServiceRolePolicy` 
- `IAMFullAccess`
- `S3` access for state storage

## Setup Instructions

### 1. Clone and Configure
```bash
git clone <repository-url>
cd aws-organization/aws-org-accounts
```

### 2. Configure Variables
```bash
# Copy example file
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
nano terraform.tfvars
```

**Required variables:**
```hcl
account_emails = {
  prod     = "prod@yourcompany.com"
  security = "security@yourcompany.com"
}

accounts = {
  prod = {
    organizational_unit = "ProdOU"
    environment        = "prod"
  }
  security = {
    organizational_unit = "SecurityOU"
    environment        = "security"
  }
}

demo_user_email = "user@yourcompany.com"
```

### 3. Enable IAM Identity Center
```bash
# Enable SSO manually in AWS Console first
# Go to IAM Identity Center → Enable
```

### 4. Deploy Infrastructure
```bash
# Initialize Terraform
terraform init

# Review planned changes
terraform plan

# Apply configuration
terraform apply
```

### 5. Access SSO Portal
After deployment, find your SSO portal URL in the outputs:
```bash
terraform output sso_portal_url
```

## Usage

### SSO Login Flow
1. User receives email invitation
2. Sets up password and MFA (if enabled)
3. Accesses portal at `https://d-xxxxxxxxxx.awsapps.com/start`
4. Selects account and role
5. Gets temporary AWS credentials

### Account Access Matrix
| User Group | Security Account | Production Account |
|------------|------------------|-------------------|
| SecurityTeam | Admin Access (8h) | ReadOnly Access (4h) |

### Service Restrictions
The Security account has SCP restrictions preventing:
- Amazon SageMaker usage
- Amazon Redshift usage  
- Amazon EMR usage

## Management

### Adding New Accounts
1. Update `terraform.tfvars`:
```hcl
accounts = {
  prod = { ... }
  security = { ... }
  dev = {
    organizational_unit = "DevOU"
    environment        = "development"
  }
}

account_emails = {
  # ... existing emails
  dev = "dev@yourcompany.com"
}
```

2. Apply changes:
```bash
terraform apply
```

### Modifying SCPs
Edit the policy in `main.tf`:
```hcl
resource "aws_organizations_policy" "security_restricted_access" {
  # Add/remove restricted services
}
```

### Managing SSO Users
- Add users via AWS Console or additional Terraform resources
- Assign users to groups for easier management
- Configure MFA requirements in SSO settings

## Cost Considerations

### Free Components
- AWS Organizations (free)
- Multiple AWS accounts (free when empty)
- IAM Identity Center (free up to 5,000 users)
- Service Control Policies (free)

### Potential Costs
- Resources deployed in accounts (EC2, S3, etc.)
- Cross-account data transfer
- CloudTrail organization trail (~$3/month)

## Security Best Practices

- ✅ Use unique email addresses for each account
- ✅ Enable MFA for all SSO users
- ✅ Implement least-privilege permission sets
- ✅ Regular access reviews and cleanup
- ✅ Monitor with CloudTrail and Config
- ✅ Use SCPs for preventive controls

## Troubleshooting

### Common Issues

**SSO Permissions Error:**
```bash
# Add SSO permissions to your Terraform user
aws iam attach-user-policy --user-name YourUser --policy-arn arn:aws:iam::aws:policy/AWSSSOServiceRolePolicy
```

**Account Deletion Fails:**
```bash
# Remove from Terraform state instead
terraform state rm 'module.accounts["prod"].aws_organizations_account.account'
```

**SCP Not Working:**
- Check if FullAWSAccess policy is attached
- Detach FullAWSAccess from OU if present
- Verify policy syntax and attachment

## Cleanup

⚠️ **Warning**: Account deletion requires manual steps

### Option 1: Remove from State
```bash
terraform state rm 'module.accounts["prod"].aws_organizations_account.account'
terraform state rm 'module.accounts["security"].aws_organizations_account.account'
terraform destroy
```

### Option 2: Manual Cleanup
1. Remove SSO assignments
2. Remove accounts from organization (requires billing info)
3. Delete organizational units
4. Delete organization

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly

## Support

For issues and questions:
- Create an issue in the repository
- Check AWS Organizations documentation
- Review Terraform AWS provider docs