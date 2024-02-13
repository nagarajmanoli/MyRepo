

#This Script is for Devl adminstrator

# Script to add users to a hostpool


$subId = "d473517e-ee7e-49e9-b43b-ac8c35c94b67" # subscription ID for above mentioned subscription
$rg = "virtual-desktop-infrastructure-devl-eastus-rg"
$hp = "HP-W10-MS-US-Test"
$ws = "AVDAppsWS"
$grName = "HP-W10-MS-US-Test-DAG"
$TenantName = "deere"


Add-RdsAppGroupUser -TenantName "deere" -HostPoolName $hp -AppGroupName $grName -UserPrincipalName "VDITeamBangalore@JohnDeere.com"

