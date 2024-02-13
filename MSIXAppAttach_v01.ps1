
[CmdletBinding()]
param (

    [Parameter()][String] $Hostpoolname = $null,     # provide hostpool name
    [Parameter()][String] $ResourceGroup  = $null,   # provide resource group name
    [Parameter()][String] $MSIXPackagePath  = $null, # Provide packagepath
    [Parameter()][String] $AppDisplayName  = $null  # Provide DisplayName
           
    )
    
$GetHostpooldetails = Get-AzWvdHostPool -ResourceGroupName $ResourceGroup -Name $HostpoolName

$AppGroupName = $GetHostpooldetails.ApplicationGroupReference.Split("/")[-1]

$subId = $GetHostpooldetails.ApplicationGroupReference.Split("/")[2]

$AppGroup = Get-AzWvdApplicationGroup -ResourceGroupName $ResourceGroup -Name $AppGroupName

$Workspacename = $AppGroup.WorkspaceArmPath.Split("/")[-1]

Get-AzWvdWorkspace -Name $Workspacename `
                   -ResourceGroupName $ResourceGroup `
                   -SubscriptionId $subID

$obj = Expand-AzWvdMsixImage -HostPoolName $Hostpoolname `
                             -ResourceGroupName $ResourceGroup `
                             -SubscriptionId $subID `
                             -Uri $MSIXPackagePath

New-AzWvdMsixPackage -HostPoolName $Hostpoolname `
                     -ResourceGroupName $ResourceGroup `
                     -SubscriptionId $subId `
                     -PackageAlias $obj.PackageAlias `
                     -DisplayName $AppDisplayName `
                     -ImagePath $MSIXPackagePath -IsActive:$true

Get-AzWvdMsixPackage -HostPoolName $Hostpoolname `
                     -ResourceGroupName $ResourceGroup `
                     -SubscriptionId $subId | Where-Object {$_.PackageFamilyName -eq $obj.PackageFamilyName}


New-AzWvdApplication -ResourceGroupName $ResourceGroup `
                     -SubscriptionId $subId `
                     -Name  $AppDisplayName `
                     -ApplicationType MsixApplication `
                     -ApplicationGroupName $AppGroupName `
                     -MsixPackageFamilyName $obj.PackageFamilyName -CommandLineSetting 0

