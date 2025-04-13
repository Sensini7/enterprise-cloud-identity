Param (
    $AzureEnvironment = "AzureUSGovernment",
    $ServicePrincipalObjectId
)

## Ensure that the setting "Access management for Azure resources" is set to "Yes" for your user
## Located at https://portal.azure.us/#view/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/~/Properties

$ContributorRoleId = (az role definition list --name "Contributor" | ConvertFrom-Json).id

az cloud set --name $AzureEnvironment
az login
az role assignment create `
    --assignee-principal-type ServicePrincipal `
    --assignee-object-id $ServicePrincipalObjectId `
    --scope "/providers/Microsoft.aadiam" --role $ContributorRoleId