
#Install Azure Modules

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




# The script will add specific user to particular host

[CmdletBinding()]
param (    
    [Parameter()][String] $Hostpoolname = $null,
    [Parameter()][String] $SessionHostName = $null,
    [Parameter()][String] $ResourceGroup  = $null,
    [Parameter()][String] $UserEmailAddress  = $null
)

Update-AzWvdSessionHost -HostPoolName $Hostpoolname -Name $SessionHostName -ResourceGroupName $ResourceGroup -AssignedUser $UserEmailAddress

#End of the line