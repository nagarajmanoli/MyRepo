


$VM = "AZW10SUSKW396"
$RGName = "virtual-desktop-infrastructure-prod-eastus-rg"
$CDriveSize = "200"
#write-host $vm.Name $vm.ResourceGroup $vm.Cdrivesize 

Stop-AzVM -ResourceGroupName $RGName -Name $VM -Force
$VMinfo = Get-AzVM -ResourceGroupName $RGName -Name $VM
$VMinfo | ConvertTo-Json

$Disk = Get-AzDisk -ResourceGroupName $vm.ResourceGroup -DiskName $VMinfo.StorageProfile.OsDisk.Name
$Disk | ConvertTo-Json

New-AzDiskUpdateConfig -DiskSizeGB $CDriveSize | Update-AzDisk -ResourceGroupName $RGName -DiskName $VMinfo.StorageProfile.OsDisk.Name

#$Disk.DiskSizeGB = $vm.Cdrivesize
#Update-AzDisk -ResourceGroupName $vm.ResourceGroup -Disk $Disk -DiskName $Disk.Name

Start-AzVM -ResourceGroupName $RGName -Name $VM

