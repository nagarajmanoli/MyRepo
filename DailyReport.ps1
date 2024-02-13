
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

#$SubscriptionName = "azure-global-hosting-network-services-prod"
#Connect-AzAccount -Tenant "39b03722-b836-496a-85ec-850f0957ca6b" -Subscription $SubscriptionName
$ResourceGroupName = "virtual-desktop-infrastructure-prod-*"
$date = Get-Date -Format yyyyMMdd
$ExistingResourceGroup = Get-AzResourceGroup -Name $ResourceGroupName

#Session hosts in all the RG
$sessionshosts = @()
foreach ($resourceGroups in $ExistingResourceGroup){
    $hostpools = Get-AzWvdHostPool -ResourceGroupName $resourceGroups.ResourceGroupName
    foreach ($hostpool in $hostpools){
        $sessionshosts += Get-AzWvdSessionHost -HostPoolName $Hostpool.Name -ResourceGroupName $resourceGroups.ResourceGroupName
    }
}
$pwrmgmdVMs = Get-AzResource -Tag @{PowerMgmt = "True" }  #specified Azure Tags
$AppIdVMs = Get-AzResource -Tag @{AppIdVM = "True" }  #Specified Azure Tags

$i=0
$count = $sessionshosts.Count
foreach($session in $sessionshosts){
    [int]$per = ($i/$count)*100  #Progress percentage
    Write-Progress -Activity "Search in Progress" -Status "$per% Complete:" -PercentComplete $per  #Progress Bar
    $sessionhostname = $session.id.Split("//")[-1]  # split the string
    $report = New-Object PSObject  # Create object 
    $assigneduser = $session.AssignedUser  #Assigned user name 
    $Ptags = "No tags"
    $Atags = "No tags"
    foreach ($pvm in $pwrmgmdVMs) {
        if ($pvm.Name -eq $($sessionhostname.split(".")[0])) {
            $Ptags = $true
            break
        }
    }
    foreach ($avm in $AppIdVMs) {
        if ($avm.Name -eq $($sessionhostname.split(".")[0])) {
            $Atags = $true
            break
        }
    }
    
    $report | Add-Member -NotePropertyName "AssignedUser" -NotePropertyValue $assigneduser
    $report | Add-Member -NotePropertyName "Session Host Name" -NotePropertyValue $sessionhostname
    $report | Add-Member -NotePropertyName "HostPool Name" -NotePropertyValue $($session.Name.Split("//")[0])
    $report | Add-Member -NotePropertyName "Status" -NotePropertyValue $session.Status
    $report | Add-Member -NotePropertyName "AllowNewSession" -NotePropertyValue $session.AllowNewSession
    $report | Add-Member -NotePropertyName "AgentVersion" -NotePropertyValue $session.AgentVersion
    $report | Add-Member -NotePropertyName "OSVersion" -NotePropertyValue $session.OSVersion
    $report | Add-Member -NotePropertyName "SxSStackVersion" -NotePropertyValue $session.SxSStackVersion
    $report | Add-Member -NotePropertyName "LastHeartBeat" -NotePropertyValue $session.LastHeartBeat
    $report | Add-Member -NotePropertyName "LastUpdateTime" -NotePropertyValue $session.LastUpdateTime
    $report | Add-Member -NotePropertyName "UpdateState" -NotePropertyValue $session.UpdateState
    $report | Add-Member -NotePropertyName "PowerMgmt" -NotePropertyValue $Ptags
    $report | Add-Member -NotePropertyName "AppIDVM" -NotePropertyValue $Atags
    $report | Export-Csv "AllSessionhosts$date.csv" -NoClobber -NoTypeInformation -Append
    $i++
}

$from = "AzDevops-noreply@johndeere.com"
$to = "VDITeamBangalore@JohnDeere.com"
$subject = "AVD Daily Report"
$body = "Report run by Azure DevOps. Do Not reply to this email"
Send-MailMessage -Attachments "AllSessionhosts$date.csv" -From $from -To $to -Subject $subject -Body $body -SmtpServer mail.dx.deere.com

<#
$allusers = Get-ADUser -Filter * -Properties SamAccountName, UserPrincipalName | Select-Object SamAccountName, UserPrincipalName
$result = @()
foreach($sessionhost in $sessionshosts){
    foreach($user in $allusers){
        if($sessionhost.AssignedUser -eq $user.UserPrincipalName)
        {
            $result += $sessionhost
            $result | Add-Member -NotePropertyName RACFID -NotePropertyValue $($user.SamAccountName) -Force
        }
    }
    
}
$result | Select-Object * | Export-Csv C:\Temp\AVDSessionhost.csv -NoClobber -NoTypeInformation
#>

<#
$report = New-Object PSObject -Property @{
    
        AssignedUser                 = $assigneduser
        Session Host Name            = $sessionhostname
        HostPool Name                = $($session.Name.Split("//")[0])
        
    }

#>