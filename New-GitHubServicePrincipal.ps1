## https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure

#Requires -Modules Az.Accounts,Az.Resources

Param (
    $AppName = "GitHub Actions",
    $TfstateResourceGroupName = "rg-tfstate",
    $TenantId,
    $SubscriptionId ,
    $GitHubOrganizationName,
    $GitHubReponame,
    $EnvironmentName,
    $NationalBoundary = "Public"
)

if (-Not (Get-AzContext)) {
    Connect-AzAccount -TenantId $TenantId -SubscriptionId $SubscriptionId -AuthScope MicrosoftGraphEndpointResourceId -EnvironmentName $NationalBoundary
}

## Create Enterprise App
$EntraApplication = New-AzADApplication -DisplayName $AppName

$clientId = $EntraApplication.AppId

## Create Service Principal
$ServicePrincipal = New-AzADServicePrincipal -ApplicationId $clientId

## Grant permissions to Terraform State resource group

$objId = $ServicePrincipal.Id

$RoleAssignments = @(
    "Contributor"
    "Storage Blob Data Contributor"
)

$RoleAssignments | ForEach-Object {
    New-AzRoleAssignment -ObjectId $objId -RoleDefinitionName $_ -Scope "/subscriptions/$SubscriptionId/resourceGroups/$TfstateResourceGroupName"
}

## Create Federated Credential
New-AzADAppFederatedCredential -ApplicationObjectId $EntraApplication.Id -Audience api://AzureADTokenExchange -Issuer 'https://token.actions.githubusercontent.com/' -Name $EnvironmentName -Subject "repo:$GitHubOrganizationName/$($GitHubReponame):environment:$EnvironmentName"