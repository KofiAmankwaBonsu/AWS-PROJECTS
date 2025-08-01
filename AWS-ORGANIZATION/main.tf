# Create Organization (once)
resource "aws_organizations_organization" "main" {
  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
    "sso.amazonaws.com",
    "account.amazonaws.com"
  ]
  
  feature_set = "ALL"
  enabled_policy_types = [
    "SERVICE_CONTROL_POLICY",
    "TAG_POLICY"
  ]
}

# Create Accounts (2 accounts for demo)
module "accounts" {
  for_each = var.accounts
  
  source                = "./modules/account"
  account_name          = title(each.key)
  account_email         = var.account_emails[each.key]
  organizational_unit   = each.value.organizational_unit
  environment          = each.value.environment
  organization_root_id = aws_organizations_organization.main.roots[0].id
}

# SSO Setup
data "aws_ssoadmin_instances" "main" {
  depends_on = [aws_organizations_organization.main]
}

locals {
  sso_instance_arn = tolist(data.aws_ssoadmin_instances.main.arns)[0]
  identity_store_id = tolist(data.aws_ssoadmin_instances.main.identity_store_ids)[0]
}

# Permission Sets
resource "aws_ssoadmin_permission_set" "admin_access" {
  name             = "AdminAccess"
  description      = "Full administrative access"
  instance_arn     = local.sso_instance_arn
  session_duration = "PT8H"
}

resource "aws_ssoadmin_permission_set" "readonly_access" {
  name             = "ReadOnlyAccess" 
  description      = "Read-only access"
  instance_arn     = local.sso_instance_arn
  session_duration = "PT4H"
}

# Attach Policies
resource "aws_ssoadmin_managed_policy_attachment" "admin_policy" {
  instance_arn       = local.sso_instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  permission_set_arn = aws_ssoadmin_permission_set.admin_access.arn
}

resource "aws_ssoadmin_managed_policy_attachment" "readonly_policy" {
  instance_arn       = local.sso_instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
  permission_set_arn = aws_ssoadmin_permission_set.readonly_access.arn
}

# Create Group
resource "aws_identitystore_group" "security_team" {
  display_name      = "SecurityTeam"
  description       = "Security team members"
  identity_store_id = local.identity_store_id
}

# Create Users
resource "aws_identitystore_user" "demo_user" {
  identity_store_id = local.identity_store_id
  display_name      = "Demo User"
  user_name         = "demo.user"
  
  name {
    given_name  = "Demo"
    family_name = "User"
  }
  
  emails {
    value   = var.demo_user_email
    primary = true
  }
}

# Add User to Group
resource "aws_identitystore_group_membership" "demo_user_membership" {
  identity_store_id = local.identity_store_id
  group_id          = aws_identitystore_group.security_team.group_id
  member_id         = aws_identitystore_user.demo_user.user_id
}

# Account Assignments
resource "aws_ssoadmin_account_assignment" "security_team_to_security_account" {
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.admin_access.arn
  
  principal_id   = aws_identitystore_group.security_team.group_id
  principal_type = "GROUP"
  
  target_id   = module.accounts["security"].account_id
  target_type = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "security_team_to_prod_account" {
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.readonly_access.arn
  
  principal_id   = aws_identitystore_group.security_team.group_id
  principal_type = "GROUP"
  
  target_id   = module.accounts["prod"].account_id
  target_type = "AWS_ACCOUNT"
}

resource "aws_organizations_policy" "security_restricted_access" {
  name        = "SecurityRestrictedAccess"
  description = "Prevent use of expensive AWS services"
  type        = "SERVICE_CONTROL_POLICY"
  
  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "*"
        Resource = "*"
      },
      {
        Effect = "Deny"
        Action = [
          "sagemaker:*",
          "redshift:*",
          "emr:*"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attachment to target SecurityOU
resource "aws_organizations_policy_attachment" "security_restricted" {
  policy_id = aws_organizations_policy.security_restricted_access.id
  target_id = module.accounts["security"].organizational_unit_id

  lifecycle {
    create_before_destroy = true
  }
}
