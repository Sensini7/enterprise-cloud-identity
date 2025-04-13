param (
    [Parameter(Mandatory = $true)]
    $TenantId,
    [Parameter(Mandatory = $true)]
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    $StorageAccountName,
    $EnvironmentName,
    $ResourceGroupName = 'rg-tfstate'
)

If (-Not(Get-Module -ListAvailable Az.Accounts)) {
    Install-Module -Name Az.Accounts -Scope CurrentUser -Repository PSGallery
}
    
Connect-AzAccount -Tenant $TenantId -Subscription $SubscriptionId


If (-Not(Get-Module -ListAvailable Az.Storage)) {
    Install-Module -Name Az.Storage -Scope CurrentUser -Repository PSGallery
}

## Create resource group
New-AzResourceGroup `
    -Name $ResourceGroupName `
    -Location eastus

# Create storage account
$storageAccount = New-AzStorageAccount `
    -ResourceGroupName $ResourceGroupName `
    -Name $StorageAccountName `
    -SkuName Standard_LRS `
    -Location eastus

# Create blob container
New-AzStorageContainer `
    -Name "tfstate" `
    -Context $storageAccount.context `
    -Permission Off ## Must be public

az login --tenant $TenantId

az account set --subscription $SubscriptionId

terraform init --backend-config="./backend/$EnvironmentName.config"

Write-Warning "Restart your shell/VS Code for the environment variables to load."