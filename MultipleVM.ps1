# Install Azure Modules 
<#
$installedPackageProvider = Get-PackageProvider
if ($installedPackageProvider.Name -notcontains "NuGet") {
    Install-PackageProvider -Name NuGet -force
    Write-Output("Install powershell module NuGet")
}
$installedModules = Get-InstalledModule
if ($installedModules.Name -notcontains "Az.Accounts") {
    Install-Module Az.Accounts -Force -AllowClobber
}
if ($installedModules.Name -notcontains "Az.Resources") {
    Install-Module Az.Resources -Force -AllowClobber
}
if ($installedModules.Name -notcontains "Az.DesktopVirtualization") {
    Install-Module Az.DesktopVirtualization -Force -AllowClobber
}
if ($installedModules.Name -notcontains "Az.Avd") {
    Install-Module Az.Avd -Force -AllowClobber
}
#>


Connect-AzAccount
#Azure Subscription I want to use
$subscriptionId = "d473517e-ee7e-49e9-b43b-ac8c35c94b67"
#Resource Group my VMs are in
$resourceGroup = "virtual-desktop-infrastructure-devl-eastus-rg"
$FileName = "\\azsmb-dce4.jdnet.deere.com\avd-profile-devl-in-vol01\Certs\ExtendDiskVolume.ps1"
# $FileName = "\\azsmb-e9df.jdnet.deere.com\avd-profile-prod-vol01\Certs\ExtendDiskVolume.ps1"
#Select the right Azure subscription
Set-AzContext -Subscription $subscriptionId

#Get all Azure VMs which are in running state and are running Windows with named VMs
$myAzureVMs = Get-AzVM -ResourceGroupName $resourceGroup -status | Where-Object {$_.PowerState -eq "VM running" -and $_.StorageProfile.OSDisk.OSType -eq "Windows" -and $_.Name -match ("AZW10SSUS") }
#$myAzureVMs = 'AZW10SINKW2725'
#Run the scirpt 
$myAzureVMs | ForEach-object {$out = Invoke-AzVMRunCommand -ResourceGroupName $_.ResourceGroupName `
    -VMName $_.Name `
    -CommandId 'RunPowerShellScript' `
    -ScriptString  '$drive_letter = "C" $size = (Get-PartitionSupportedSize -DriveLetter $drive_letter) Resize-Partition -DriveLetter $drive_letter -Size $size.SizeMax'
#Formating the Output with the VM name
$output = $_.Name + " " + $out.Value[0].Message
$output   
}


