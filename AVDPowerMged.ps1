Clear-Host
$installedPackageProvider = Get-PackageProvider
if ($installedPackageProvider.Name -notcontains "NuGet") {
    Install-PackageProvider -Name NuGet -force
    Register-PackageSource -Name nuget.org -Location https://www.nuget.org/api/v2 -ProviderName NuGet
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
    Import-Module ActiveDirectory -Force
}

$TenantId = "39b03722-b836-496a-85ec-850f0957ca6b"
$SubscriptionName = "azure-global-hosting-network-services-prod"
# $SubscriptionName = "azure-global-hosting-network-services-devl"
Connect-AzAccount -Tenant $TenantId -Subscription $SubscriptionName
#$ResourceGroupName = "virtual-desktop-infrastructure-prod-*"
$date = Get-Date -Format yyyyMMdd
#$ExistingResourceGroup = Get-AzResourceGroup -Name $ResourceGroupName

$Query = '
WVDConnections  
| where TimeGenerated > ago(30d)  
| where State == "Connected"  
| project CorrelationId , UserName, ConnectionType , StartTime=TimeGenerated , SessionHostName , _ResourceId
| join (WVDConnections  
    | where State == "Completed"  
    | project EndTime=TimeGenerated, CorrelationId)  
    on CorrelationId  
| project Duration =EndTime - StartTime, ConnectionType, UserName , SessionHostName , _ResourceId
| summarize TotalDuration=sum(Duration) by UserName , SessionHostName , _ResourceId
| where TotalDuration <= timespan(80hours)
| extend Multi=split(_ResourceId, "/")
| project UserName, SessionHostName, TotalDuration, ResourceGroup=Multi[4], HostPool=Multi[8]
| sort by TotalDuration asc '
 

$WorkspaceId = '5fc568f4-fea3-4beb-a753-477a0bf9da4c'
 
$ResultList = Invoke-AzOperationalInsightsQuery -WorkspaceId $WorkspaceID -Query $Query -ErrorAction Stop | Select-Object -ExpandProperty Results

# $ResultList | Format-Table

$ResultList | Export-Csv -Path C:\Temp\AVD-enabled-pwrmgmt-$date.csv -NoClobber -NoTypeInformation

foreach($user in $ResultList){
    $ResourceGroupName = $user.ResourceGroup
    $vmname = $($user.SessionHostName).split('.')[0]
    $getvm = Get-AzVm -ResourceGroupName $resourceGroupName -Name $vmname
    If($null -ne $getvm){
        $resourcedets = Get-AzResource -ResourceGroupName $ResourceGroupName -Name $vmname
        $tags = $resourcedets.Tags
        $resourceid = $resourcedets.ResourceId
        if(($null -ne $tags) -and ($getvm.Name -notcontains "RPA")){
                If($tags.PowerMgmt -ne $true){
                    $newtag = @{PowerMgmt="True"}
                    Update-AzTag -ResourceId $resourceid -Tag $newtag -Operation Merge
                }
                elseif ($null -eq $tags.PowerMgmt) {
                    $tags += @{PowerMgmt="True"}
                    Set-AzResource -ResourceGroupName $ResourceGroupName -Name $vmname -ResourceType "Microsoft.Compute/VirtualMachines" -Tag $tags
                }
        }
        else{
            $tags += @{PowerMgmt="True"}
            Set-AzResource -ResourceGroupName $ResourceGroupName -Name $vmname -ResourceType "Microsoft.Compute/VirtualMachines" -Tag $tags
        }
    }
}

$pwrmgmdVMs = Get-AzResource -Tag @{PowerMgmt = "True" }
$ResultList = @()

foreach($pwrvm in $pwrmgmdVMs){
$Query = "
WVDConnections  
| where TimeGenerated > ago(30d)  
| where SessionHostName == `"$($pwrvm.Name).jdnet.deere.com`"
| where State == `"Connected`"  
| project CorrelationId , UserName, ConnectionType , StartTime=TimeGenerated , SessionHostName , _ResourceId
| join (WVDConnections  
    | where State == `"Completed`"  
    | project EndTime=TimeGenerated, CorrelationId)  
    on CorrelationId  
| project Duration =EndTime - StartTime, ConnectionType, UserName , SessionHostName , _ResourceId
| summarize TotalDuration=sum(Duration) by UserName , SessionHostName , _ResourceId
| where TotalDuration >= timespan(120hours)
| extend Multi=split(_ResourceId, `"/`")
| project UserName, SessionHostName, TotalDuration, ResourceGroup=Multi[4], HostPool=Multi[8]
| sort by TotalDuration asc "

$WorkspaceId = '5fc568f4-fea3-4beb-a753-477a0bf9da4c'
 
$ResultList += Invoke-AzOperationalInsightsQuery -WorkspaceId $WorkspaceID -Query $Query -ErrorAction Stop | Select-Object -ExpandProperty Results

}

$ResultList | Export-Csv -Path C:\Temp\AVD-pwrmgmt-disable-$date.csv -NoClobber -NoTypeInformation -Append

foreach($vm in $ResultList){
    $ResourceGroupName = $vm.ResourceGroup
    $vmname = $vm.Name
    $getvm = Get-AzVm -ResourceGroupName $resourceGroupName -Name $vmname
    If($null -ne $getvm){
        $resourcedets = Get-AzResource -ResourceGroupName $ResourceGroupName -Name $vmname
        $tags = $resourcedets.Tags
        $resourceid = $resourcedets.ResourceId
        if($getvm.Name -notcontains "RPA"){
            $newtag = @{PowerMgmt="False"}
            Update-AzTag -ResourceId $resourceid -Tag $newtag -Operation Merge
        }
    }
}