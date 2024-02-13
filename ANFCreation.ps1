


# Create ANF Capacity pool

$installedModules = Get-InstalledModule
if ($installedModules.Name -notcontains "Az.NetAppFiles") {
    Install-Module Az.NetAppFiles -Force -AllowClobber
}

$ResourceGroup = "virtual-desktop-infrastructure-prod-centralindia-rg"
$SubID = "7260d3cc-139c-483d-8b34-1da7d1c5d992"
$Servicelevel = "Ultra"
$AccountName = "avd-profile-prod-in"
$VirtualNetwork = "global-hosting-network-services-prod-centralindia-vpn"
$SubnetName  = "virtual-desktop-infra-prod-application2-subnet"
$poolname = "avd-profile-prod-in-cap-pool1"




#Create Capacity pool
#New-AzNetAppFilesPool -ResourceGroupName $ResourceGroup -AccountName $AccountName -Name "avd-profile-prod-in-cap-pool1" -Location "Centralindia" -PoolSize 4398046511104 -ServiceLevel Ultra -QosType "Auto"

Create Volume
New-AzNetAppFilesVolume -ResourceGroupName $ResourceGroup -AccountName $AccountName -PoolName "avd-profile-prod-in-cap-pool1" -Name "avd-profile-prod-in-vol02" -Location "Centralindia" -CreationToken "avd-profile-prod-in-vol02" -UsageThreshold 107374182400 -ServiceLevel Ultra -ProtocolType CIFS -SubnetId "/subscriptions/$SubID/resourceGroups/$ResourceGroup/providers/Microsoft.Network/virtualNetworks/$VirtualNetwork/subnets/$SubnetName"

#Remove Volume
#Remove-AzNetAppFilesVolume -ResourceGroupName $ResourceGroup -AccountName $AccountName -PoolName $poolname -Name "avd-profile-prod-in-vol02"