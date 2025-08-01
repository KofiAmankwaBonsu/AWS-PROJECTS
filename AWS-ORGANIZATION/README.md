# AWS Organization Accounts Setup

This project is designed to create and manage multiple AWS accounts using Terraform within an AWS Organization. It includes configurations for three distinct environments: Production (Prod), Non-Production (NonProd), and Security.

## Project Structure

The project is organized as follows:

```
aws-org-accounts
├── modules
│   └── account
│       ├── main.tf          # Main configuration for creating an AWS account
│       ├── variables.tf     # Input variables for the account module
│       └── outputs.tf       # Outputs of the account module
├── environments
│   ├── prod
│   │   └── main.tf          # Configuration for the Production environment
│   ├── nonprod
│   │   └── main.tf          # Configuration for the Non-Production environment
│   └── security
│       └── main.tf          # Configuration for the Security environment
├── main.tf                  # Entry point for the Terraform configuration
├── variables.tf             # Global input variables for the project
├── outputs.tf               # Global outputs for the project
├── terraform.tfvars         # Variable values for the Terraform project
└── README.md                # Documentation for the project
```

## Setup Instructions

1. **Prerequisites**: Ensure you have Terraform installed and configured on your machine. You will also need AWS credentials with permissions to create accounts in AWS Organizations.

2. **Clone the Repository**: Clone this repository to your local machine.

3. **Configure Variables**: Update the `terraform.tfvars` file with your specific values for account names, emails, and any other necessary configurations.

4. **Initialize Terraform**: Navigate to the project directory and run:
   ```
   terraform init
   ```

5. **Plan the Deployment**: To see what resources will be created, run:
   ```
   terraform plan
   ```

6. **Apply the Configuration**: To create the accounts, run:
   ```
   terraform apply
   ```

7. **Outputs**: After the apply completes, you can view the outputs defined in the `outputs.tf` files to get information about the created accounts.

## Usage Guidelines

- Each environment (Prod, NonProd, Security) has its own configuration file that calls the account module. You can modify these files to customize the account creation process for each environment.
- The `modules/account` directory contains reusable Terraform code for creating AWS accounts, which can be referenced in the environment-specific configurations.

## Contributing

Feel free to submit issues or pull requests if you have suggestions or improvements for this project.