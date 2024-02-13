
Connect-AzAccount
Set-AzContext -Subscription "azure-global-hosting-network-services-prod"
$workspaceName = "AVD-Log-Analytics-Workspace-EUS"
$workspaceRG = "virtual-desktop-infrastructure-prod-eastus-rg"
$WorkspaceID = (Get-AzOperationalInsightsWorkspace -Name $workspaceName -ResourceGroupName $workspaceRG).CustomerID
$query = 'WVDConnectionNetworkData

| join kind=leftouter (
    WVDConnections
    | distinct CorrelationId, UserName, SessionHostName
) on CorrelationId
| where TimeGenerated > ago (1h)
| summarize AvgRTT=avg(EstRoundTripTimeInMs),RTT_P95=percentile(EstRoundTripTimeInMs,95) by UserName, SessionHostName
|  where AvgRTT > 500'



$kqlQuery = Invoke-AzOperationalInsightsQuery -WorkspaceId $WorkspaceID -Query $query

$Affectedusers=$kqlQuery.Results.UserName
$YourRTT=$kqlQuery.Results.AvgRTT
$AffectedHost=$kqlQuery.Results.SessionHostName
$Affectedusers
$YourRTT
$AffectedHost


$name = "AZW10MINKW-1","AZW10MINKW-0"
$msg = "Hello, Your connection to Azure Virtual Desktop is poor with Round Trip Time value 25ms, for optimal performance switch to better network"
#Invoke-WmiMethod -Path Win32_Process -Name Create -ArgumentList "msg * $msg" -ComputerName $name

foreach($impactedHost in $name)
{
    Invoke-WmiMethod -Path Win32_Process -Name Create -ArgumentList "msg * $msg" -ComputerName $impactedHost
  
}






<#
foreach($imapctedusers in $Affectedusers)
{
    $from = "AzDevops-noreply@johndeere.com"
    $to =  "$impactedusers"
    $subject = "Hello, Your connection to Azure Virtual Desktop is poor with Round Trip Time value $YourRTT, for optimal performance switch to better network"
    $body = "Report run by Azure DevOps. Do Not reply to this email"
    $smtpserver = "mail.dx.deere.com"
    Send-MailMessage -From $from -To $to -Subject $subject -Body $body -SmtpServer $smtpserver
   
}

$kqlQuery.Results| Export-Csv "RTT.csv" -NoClobber -NoTypeInformation -Append
$from = "AzDevops-noreply@johndeere.com"
$to =  "manolinagaraj@JohnDeere.com"
$subject = "RTT > 300ms"
$body = "Report run by Azure DevOps. Do Not reply to this email"
$smtpserver = "mail.dx.deere.com"
Send-MailMessage -Attachments "RTT.csv" -From $from -To $to -Subject $subject -Body $body -SmtpServer $smtpserver

#>