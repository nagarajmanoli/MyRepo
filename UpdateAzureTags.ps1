


#Connect-AzAccount
#Azure Subscription I want to use
$subscriptionId = "7260d3cc-139c-483d-8b34-1da7d1c5d992"
#Resource Group my VMs are in
$resourceGroup = "virtual-desktop-infrastructure-prod-centralindia-rg"

Set-AzContext -Subscription $subscriptionId
$VM = Get-AzVM -Name "AZW10SINKW2576"
$tags = @{AccessRevokedOn='20221123'; DecommDate='12/03/2022 04:33:30'; Inactivedays='86'}

Update-AzTag -ResourceId $VM.Id -Tag $tags -Operation Delete -Verbose