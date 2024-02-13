

#Create RemoteApp Group on the Particular host pool

$subId = "7260d3cc-139c-483d-8b34-1da7d1c5d992" # subscription ID for above mentioned subscription
$rg = "virtual-desktop-infrastructure-prod-centralindia-rg"
$hp = "HP-W10-MS-IN-KW"
$ws = "WS-W10-MS-IN"
$RAG = "HP-W10-MS-IN-KW-RAG"

New-AzWvdApplicationGroup -Name HP-W10-MS-IN-KW-RAG -ResourceGroupName virtual-desktop-infrastructure-prod-centralindia-rg -ApplicationGroupType "RemoteApp" -WorkspaceName WS-W10-MS-IN -HostPoolArmPath '/subscriptions/7260d3cc-139c-483d-8b34-1da7d1c5d992/resourcegroups/virtual-desktop-infrastructure-prod-centralindia-rg/providers/Microsoft.DesktopVirtualization/hostPools/HP-W10-MS-IN-KW'-Location eastus

Register-AzWvdApplicationGroup -ResourceGroupName $rg -WorkspaceName $ws -ApplicationGroupPath '/subscriptions/7260d3cc-139c-483d-8b34-1da7d1c5d992/resourceGroups/virtual-desktop-infrastructure-prod-centralindia-rg/providers/Microsoft.DesktopVirtualization/applicationGroups/HP-W10-MS-IN-KW-RAG'

New-AzRoleAssignment -SignInName VDITeamBangalore@JohnDeere.com -RoleDefinitionName "Desktop Virtualization User" -ResourceName $RAG -ResourceGroupName $rg -ResourceType 'Microsoft.DesktopVirtualization/applicationGroups'

# Remove-AzWvdApplicationGroup -Name HP-W10-MS-IN-KW-RAG -ResourceGroupName virtual-desktop-infrastructure-prod-centralindia-rg




