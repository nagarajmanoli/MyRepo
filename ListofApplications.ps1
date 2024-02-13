

Connect-AzAccount
Set-AzContext -Subscription "azure-global-hosting-network-services-devl"
$ResourceGroup = "virtual-desktop-infrastructure-devl-eastus-rg"

$list = "AZW10MSVM01-1"
foreach($PC in $list)
{
    $Apps= Get-WmiObject Win32_Product -ComputerName $PC | select Name,Version  
    $Apps | Export-csv  c:\output.csv -Append
    }

       
    