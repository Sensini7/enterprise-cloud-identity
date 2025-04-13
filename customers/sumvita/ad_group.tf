moved {
  from = azuread_group.breakglass-group
  to   = azuread_group.emergency-access-group
}

# Group for the emergency breakglass users
resource "azuread_group" "emergency-access-group" {
  display_name     = "Emergency Access Group"
  owners           = var.default_group_owners_ids
  description      = "Holds Emergency Breakglass accounts. Can be used for excluding the accounts from conditional access policies."
  security_enabled = true
  mail_enabled     = false

  lifecycle {
    ignore_changes = [
      members
    ]
  }
}

resource "azuread_group" "excluded_from_conditional_access_group" {
  display_name     = "CAP Exclude - All Policies"
  owners           = var.default_group_owners_ids
  description      = "Excluded from all conditional access policies."
  security_enabled = true
  mail_enabled     = false

  lifecycle {
    ignore_changes = [
      members
    ]
  }
}
