

# Connect-AzAccount
# Set-AzContext -Subscription "azure-global-hosting-network-services-prod"
# $ResourceGroupName = "virtual-desktop-infrastructure-prod-centralindia-rg"
# $obj = Select-AzContext -Name "azure-global-hosting-network-services-prod"




$subId = "7260d3cc-139c-483d-8b34-1da7d1c5d992" # subscription ID for above mentioned subscription
$rg = "virtual-desktop-infrastructure-prod-centralindia-rg"
$hp = "HP-W10-MS-IN-KW"
$ws = "WS-W10-MS-IN"
Get-AzWvdWorkspace -Name $ws -ResourceGroupName $rg -SubscriptionId $subID
$obj = Expand-AzWvdMsixImage -HostPoolName $hp -ResourceGroupName $rg -SubscriptionId $subID -Uri "\\azsmb-8301.jdnet.deere.com\avd-profile-prod-in-vol01\AppAttchContainers\notepadplus.vhdx"
New-AzWvdMsixPackage -HostPoolName $hp -ResourceGroupName $rg -SubscriptionId $subId -PackageAlias $obj.PackageAlias -DisplayName NotepadPlus -ImagePath "\\azsmb-8301.jdnet.deere.com\avd-profile-prod-in-vol01\AppAttchContainers\notepadplus.vhdx" -IsActive:$true
Get-AzWvdMsixPackage -HostPoolName $hp -ResourceGroupName $rg -SubscriptionId $subId | Where-Object {$_.PackageFamilyName -eq $obj.PackageFamilyName}


$grName = "notepadplusaa"
# New-AzWvdApplicationGroup -Name $grName -ResourceGroupName $rg -ApplicationGroupType "RemoteApp" -HostPoolArmPath '/subscriptions/SubscriptionId/resourcegroups/ResourceGroupName/providers/Microsoft.DesktopVirtualization/hostPools/HostPoolName'-Location EastUS
New-AzWvdApplication -ResourceGroupName $rg -SubscriptionId $subId -Name NotepadPlus -ApplicationType MsixApplication -ApplicationGroupName $grName -MsixPackageFamilyName $obj.PackageFamilyName -CommandLineSetting 0
# New-AzWvdApplication -ResourceGroupName $rg -SubscriptionId $subId -Name NotepadPlus -ApplicationType MsixApplication -ApplicationGroupName $grName -MsixPackageFamilyName $obj.PackageFamilyName -CommandLineSetting 0 -MsixPackageApplicationId $obj.PackageApplication.AppId


