
Connect-AzAccount
Set-AzContext -Subscription "azure-global-hosting-network-services-devl"

$installedPackageProvider = Get-PackageProvider
if ($installedPackageProvider.Name -notcontains "NuGet") {
    Install-PackageProvider -Name NuGet -force
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
if ($installedModules.Name -notcontains "Az.KeyVault") {
    Install-Module Az.KeyVault -Force -AllowClobber
}
if ($installedModules.Name -notcontains "Microsoft.Graph") {
    Install-Module -Name Microsoft.Graph -Force -AllowClobber
}
if ($installedModules.Name -notcontains "ActiveDirectory") {
    Install-WindowsFeature RSAT-AD-PowerShell
    Import-Module ActiveDirectory -Force
}

<#

[CmdletBinding()]
param (
    [Parameter()][String] $Hostpoolname = $null,     # provide hostpool name
    [Parameter()][String] $ResourceGroup  = $null,   # provide resource group name
    [Parameter()][String] $MSIXPackageName  = $null, # Provide packagename ex:"NotepadPlus_8.4.6.0_x64__70w54f1edgcma"
    [Parameter()][String] $AppDisplayName  = $null,  # Provide DisplayName  ex: NotepadPlus
    [Parameter()][Switch] $RemoveApplication  = $false,    # Remove Application from Desktop App Group
    [Parameter()][Switch] $RemoveMSIXPackage  = $false,    # Remove Application from Desktop App Group
    [Parameter()][Switch] $Active  = $false,
    [Parameter()][Switch] $Inactive  = $false
    ) 
#>
$Hostpoolname = "HP-W10-SS-US-AppTest"
$ResourceGroup  = "virtual-desktop-infrastructure-devl-eastus-rg"
$MSIXPackageName  = "NotepadPlus_8.4.6.0_x64__70w54f1edgcma"
$AppDisplayName  = "NotePadPluS"
$RemoveApplication  = $false
$RemoveMSIXPackage  = $True
$Active  = $false
$Inactive  = $false


$GetHostpooldetails = Get-AzWvdHostPool -ResourceGroupName $ResourceGroup -Name $HostpoolName

$AppGroupName = $GetHostpooldetails.ApplicationGroupReference.Split("/")[-1]

$subId = $GetHostpooldetails.ApplicationGroupReference.Split("/")[2]

$AppGroup = Get-AzWvdApplicationGroup -ResourceGroupName $ResourceGroup -Name $AppGroupName

$Workspacename = $AppGroup.WorkspaceArmPath.Split("/")[-1]
   

if ($RemoveApplication)
{
Remove-AzWvdApplication -ResourceGroupName $ResourceGroup -ApplicationGroupName $AppGroupName -Name $AppDisplayName
}

if($RemoveMSIXPackage)
{
Remove-AzWvdMsixPackage -HostPoolName $Hostpoolname -ResourceGroupName $ResourceGroup -SubscriptionId $subId -FullName $MSIXPackageName
}

if ($Active)
{

Update-AzWvdMsixPackage -FullName $MSIXPackageName `
-HostPoolName $Hostpoolname `
-ResourceGroupName $ResourceGroup `
-SubscriptionId $subId `
-displayName $AppDisplayName `
-IsActive:$True 
}

if($Inactive)
{
Update-AzWvdMsixPackage -FullName $MSIXPackageName `
 -HostPoolName $Hostpoolname `
-ResourceGroupName $ResourceGroup `
-SubscriptionId $subId `
-displayName $AppDisplayName `
-IsActive:$false 
}


   