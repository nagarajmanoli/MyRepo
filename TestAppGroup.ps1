

Connect-AzAccount
Set-AzContext -Subscription "azure-global-hosting-network-services-devl"
$ResourceGroup = "virtual-desktop-infrastructure-devl-eastus-rg"
$HostpoolName = "HP-W10-SS-US-AppTest"

Get-AzWvdHostPool 

$MSIXPackageFileName = "NPP.vhdx"
$MSIXPackagePath = "\\azsmb-dce4.jdnet.deere.com\avd-profile-devl-in-vol01\AppAttachContainer\" + $MSIXPackageFileName
$MSIXPackagePath


$GetHostpooldetails= Get-AzWvdHostPool -ResourceGroupName $ResourceGroup -Name $HostpoolName

$AppGroupName = $GetHostpooldetails.ApplicationGroupReference.Split("/")[2]

$AppGroupName

$Workspace= Get-AzWvdApplicationGroup -ResourceGroupName $ResourceGroup -Name $AppGroupName

$Workspace.WorkspaceArmPath.Split("/")[-1]



<#
$AppGroup = "HP-W10-SS-US-AppTest-DAG"

$AppGroupName = Get-AzWvdApplicationGroup -ResourceGroupName $ResourceGroup -Name $AppGroup

$AppGroupName.WorkspaceArmPath.Split("/")[-1]
#>