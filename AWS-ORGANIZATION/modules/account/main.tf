resource "aws_organizations_organizational_unit" "ou" {
  name      = var.organizational_unit
  parent_id = var.organization_root_id
}

resource "aws_organizations_account" "account" {
  name      = var.account_name
  email     = var.account_email
  role_name = "OrganizationAccountAccessRole"
  parent_id = aws_organizations_organizational_unit.ou.id

  tags = merge(
    {
      Environment = var.environment
    },
    var.tags
  )
}