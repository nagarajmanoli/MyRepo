

#Connect-AzAccount
#Set-AzContext -Subscription "azure-global-hosting-network-services-prod"
$workspaceName = "AVD-Log-Analytics-Workspace-EUS"
$workspaceRG = "virtual-desktop-infrastructure-prod-eastus-rg"
$WorkspaceID = (Get-AzOperationalInsightsWorkspace -Name $workspaceName -ResourceGroupName $workspaceRG).CustomerID
$query = 'Perf 
| where ObjectName == "Memory"
| where CounterName == "% Used Memory" or CounterName == "% Committed Bytes In Use"
| where TimeGenerated > ago(7d)
| summarize AVG_MEMORY = avg(CounterValue), MAX_MEMORY = max(CounterValue)  by Computer,  _ResourceId
| join
(
Perf
| where ObjectName == "Processor" and CounterName == "% Processor Time" and InstanceName == "_Total"
| where Computer in ((Heartbeat | where OSType == "Windows" | distinct Computer))
| where TimeGenerated > ago(7d)
| summarize AVG_CPU = avg(CounterValue), MAX_CPU = max(CounterValue) by Computer
) on Computer
| project Computer, AVG_CPU, MAX_CPU, AVG_MEMORY, MAX_MEMORY
| where AVG_CPU > 50 and AVG_MEMORY > 50'
$kqlQuery = Invoke-AzOperationalInsightsQuery -WorkspaceId $WorkspaceID -Query $query
$kqlQuery.Results
$kqlQuery.Results| Export-Csv "CPUandRAM.csv" -NoClobber -NoTypeInformation -Append
$from = "AzDevops-noreply@johndeere.com"
$to = "kumardubasantosh@Johndeere.com", "manolinagaraj@JohnDeere.com"
$subject = "AVD CPU & RAM > 50%"
$body = "Report run by Azure DevOps. Do Not reply to this email"
$smtpserver = "mail.dx.deere.com"
Send-MailMessage -Attachments "CPUandRAM.csv" -From $from -To $to -Subject $subject -Body $body -SmtpServer $smtpserver