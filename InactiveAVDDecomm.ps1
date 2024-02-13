Clear-Host
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

$TenantId = "39b03722-b836-496a-85ec-850f0957ca6b"
$SubscriptionName = "azure-global-hosting-network-services-prod"
Connect-AzAccount -Tenant $TenantId -Subscription $SubscriptionName
$ResourceGroupName = "virtual-desktop-infrastructure-prod-*"
$date = Get-Date -Format yyyyMMdd
$ExistingResourceGroup = Get-AzResourceGroup -Name $ResourceGroupName
## Collecting all Active Sessionhosts
$sessionshosts = @()
foreach ($resourceGroups in $ExistingResourceGroup){
    $hostpools = Get-AzWvdHostPool -ResourceGroupName $resourceGroups.ResourceGroupName
    foreach ($hostpool in $hostpools){
        $sessionshosts += Get-AzWvdSessionHost -HostPoolName $Hostpool.Name -ResourceGroupName $resourceGroups.ResourceGroupName
    }
}

## Getting user details assinged to Sessionhosts
$i=1
$count = $sessionshosts.Count
foreach($session in $sessionshosts){
    [int]$per = ($i/$count)*100
    Write-Progress -Activity "Report in Progress" -Status "$per% Complete:" -PercentComplete $per
    $sessionhostname = $session.id.Split("//")[-1]
    $report = New-Object PSObject
    $assigneduser = $session.AssignedUser
    if($null -ne $assigneduser){
        $report | Add-Member -NotePropertyName "AssignedUser" -NotePropertyValue $assigneduser
        $report | Add-Member -NotePropertyName "SessionHostName" -NotePropertyValue $sessionhostname
        $report | Add-Member -NotePropertyName "HostPoolName" -NotePropertyValue $($session.Name.Split("//")[0])
        $report | Add-Member -NotePropertyName "ResourceGroupName" -NotePropertyValue $($session.Id.Split("//")[4])
        $report | Export-Csv "AllSessionhosts$date.csv" -NoClobber -NoTypeInformation -Append
    }
    $i++
}

## Getting the RACF ID from the User's email ID
Connect-MgGraph -Scopes 'User.Read.All'
$users = Import-Csv "AllSessionhosts$date.csv"
$count = $users.Count
$i = 1
foreach($user in $users)
{
    [int]$per = ($i/$count)*100
    Write-Progress -Activity "AAD search in Progress" -Status "$per% Complete:" -PercentComplete $per
    $details = Get-MgUser -UserId $user.AssignedUser -Select id, DisplayName, UserPrincipalName, AccountEnabled, OnPremisesSamAccountName
    $details | Export-Csv AllAADuserdetails$date.csv -NoClobber -NoTypeInformation -Append
    $i++
}

## Getting inactive user list for on-perm AD
$aadusers = Import-Csv "AllAADuserdetails$date.csv"
$count = $aadusers.Count
$i = 1
foreach($aaduser in $aadusers)
{
    [int]$per = ($i/$count)*100
    Write-Progress -Activity "AAD search in Progress" -Status "$per% Complete:" -PercentComplete $per
    $addetails = Get-ADUser -Identity $aaduser.OnPremisesSamAccountName | Select-Object SamAccountName, UserPrincipalName, Enabled
    if($aaduser.Enabled -eq $false){
        $addetails | Export-Csv inactiveADuserdetails$date.csv -NoClobber -NoTypeInformation -Append
    }
    $i++
}

## Getting all the session host of inactive users
$inactusers = Import-Csv "inactiveADuserdetails$date.csv"
$count = $inactusers.Count
$i = 1
foreach($inactuser in $inactusers)
{
    [int]$per = ($i/$count)*100
    Write-Progress -Activity "Find inacitve session host in Progress" -Status "$per% Complete:" -PercentComplete $per
    foreach($user in $users)
    {
        if($inactuser.UserPrincipalName -eq $user.AssignedUser){
            $user | Export-Csv InactiveSessionhostUsers$date.csv -NoClobber -NoTypeInformation -Append
        }
    }
    $i++
}

## Removing all the session host of inactive users
$inactsessions = Import-Csv "InactiveSessionhostUsers$date.csv"
$count = $inactsessions.Count
$i = 1
foreach($inactsession in $inactsessions)
{
    [int]$per = ($i/$count)*100
    Write-Progress -Activity "Deleting inacitve session host in Progress" -Status "$per% Complete:" -PercentComplete $per
    try {

        Get-AzVm -ResourceGroupName $inactsession.ResourceGroupName -Name $inactsession.SessionHostName | Remove-AzVM -Force -Confirm:$false
        Get-AzDisk -ResourceGroupName $inactsession.ResourceGroupName -Name $($inactsession.SessionHostName+"*") | Remove-AzDisk -Force -Confirm:$false
        Get-AzNetworkInterface -ResourceGroupName $inactsession.ResourceGroupName -Name $($inactsession.SessionHostName+"*") | Remove-AzNetworkInterface -Force -Confirm:$false
    }
    catch {
        {1:Write-Host "$($inactsession.SessionHostName) delete Failed "}
    }
    try{
        Remove-AzWvdSessionHost -HostpoolName $inactsession.HostPoolName -ResourceGroupName $inactsession.ResourceGroupName -SessionHostName $inactsession.SessionHostName
    }
    catch {
        {1: Write-Host "$($inactsession.SessionHostName) not removed from Hostpool"}
    }
    

    $i++
}

<#
$from = "AzDevops-noreply@johndeere.com"
$to = "VDITeamBangalore@JohnDeere.com"
$subject = "AVD Daily Report"
$body = "Report run by Azure DevOps. Do Not reply to this email"
Send-MailMessage -Attachments "AllSessionhosts$date.csv" -From $from -To $to -Subject $subject -Body $body -SmtpServer mail.dx.deere.com
=======
    $i++
}

#>