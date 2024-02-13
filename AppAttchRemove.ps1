



$subId = "7260d3cc-139c-483d-8b34-1da7d1c5d992" # subscription ID for above mentioned subscription
$rg = "virtual-desktop-infrastructure-prod-centralindia-rg"
$hp = "HP-W10-MS-IN-KW"
$ws = "WS-W10-MS-IN"
$grName = "HP-W10-MS-IN-KW-DAG"

Get-AzWvdMsixPackage -HostPoolName $hp -ResourceGroupName $rg -SubscriptionId $subId
Remove-AzWvdMsixPackage -FullName "NotepadPlus_8.4.6.0_x64__70w54f1edgcma" -HostPoolName $hp -ResourceGroupName $rg


Remove-AzWvdApplication -ResourceGroupName $rg -ApplicationGroupName $grName -Name NotepadPlus