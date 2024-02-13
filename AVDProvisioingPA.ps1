[CmdletBinding()]
param (
    
    [Parameter()]
    [ValidateSet("US", "EU", "IN")]
    [String] $Region,
    [Parameter()] 
    [ValidateSet("KW", "SD", "DEV", "ENG", "RPA", "RPU", "PRO", "APP", "APPID", "PRNTEXCP", "CPYEXCP", "APPIDUSR")]
    [String] $Usertype,
    [Parameter()] 
    [ValidateSet("Prod", "Devl")]
    [String] $Environment = "Devl",
    [Parameter()] 
    [ValidateSet("Persistent", "Pooled")]
    [String] $VMHPType = "Persistent",
    [Parameter()] [int] $sessionHostCount = 1,
    [Parameter(Mandatory = $true)] [String] $requestedby,
    [Parameter(Mandatory = $true)] [String] $requestedFor,
    [Parameter(Mandatory = $true)] [String] $enduseremail
)

$HostPoolName = "HP-W10"
$workspacesName = "WS-W10"
$avdPrefix = "AZW10"


switch ($Environment) {
    Prod { 
        $SubscriptionName = "azure-global-hosting-network-services-prod"
        $avdkeyvaultname = "AVDKeyValult-Prod"
        $avdkeyvaultRG = "virtual-desktop-infrastructure-prod-eastus-rg"
        $IMResourceGroupName = "virtual-desktop-infrastructure-prod-eastus-rg"
        $ImageGalleryName = "AVD_Prod_Image_Gallery"
        $ImageName = "AVD_Prod_KW_Image"
    }
    Devl {
        $SubscriptionName = "azure-global-hosting-network-services-devl"
        $avdkeyvaultname = "avd-vault-devl"
        $avdkeyvaultRG = "ioarch-wvd-poc-devl-eastus-rg"
        $IMResourceGroupName = "ioarch-wvd-poc-devl-eastus-rg"
        $ImageGalleryName = "AVD_POC_Images"
        $ImageName = "WinX_DeereImagev1"
    }
    Default {}
}

switch ($VMHPType) {
    Persistent { 
        $HostPoolName = $HostPoolName + "-SS"
        $workspacesName = $workspacesName + "-SS"
        $avdPrefix = $avdPrefix + "S"        
    }
    Pooled {
        $HostPoolName = $HostPoolName + "-MS"
        $workspacesName = $workspacesName + "-MS"
        $avdPrefix = $avdPrefix + "M"
    }
}
switch ($Region) {
    US {
        $HostPoolName = $HostPoolName + "-US"
        $avdPrefix = $avdPrefix + "US"
        $workspacesName = $workspacesName + "-US"
        if ($Environment -eq "Prod") {
            $ResourceGroupName = "virtual-desktop-infrastructure-prod-eastus-rg"
            $VMNetworkResourceGroupName = "global-hosting-network-services-prod-eastus-network-rg"
            $VMNetworkName = "global-hosting-network-services-prod-eastus-vpn2"
            $SubnetName = "virtual-desktop-infrastructure-prod-subnet-application"
        }
        else {
            $ResourceGroupName = "virtual-desktop-infrastructure-devl-eastus-rg"
            $VMNetworkResourceGroupName = "global-hosting-network-services-devl-eastus-network-rg"
            $VMNetworkName = "global-hosting-network-services-devl-eastus-vpn1"
            $SubnetName = "virtual-desktop-infrastructure-devl-subnet-application"
            $HostPoolName = $HostPoolName + "-devl"
            $avdPrefix = $avdPrefix + "D"
            $workspacesName = $workspacesName + "-devl"
        }
    }
    EU {
        $HostPoolName = $HostPoolName + "-EU"
        $avdPrefix = $avdPrefix + "EU"
        $workspacesName = $workspacesName + "-EU"
        if ($Environment -eq "Prod") {
            $ResourceGroupName = "virtual-desktop-infrastructure-prod-germanywestcentral-rg"
            $VMNetworkResourceGroupName = "global-hosting-network-servs-prod-germanywestcentral-network-rg"
            $VMNetworkName = "global-hosting-network-services-prod-germanywestcentral-vpn"
            $SubnetName = "virtual-desktop-infrastructure-prod-application-subnet"
        }
        else {
            $ResourceGroupName = "virtual-desktop-infrastructure-devl-eastus-rg"
            $VMNetworkResourceGroupName = "global-hosting-network-services-devl-eastus-network-rg"
            $VMNetworkName = "global-hosting-network-services-devl-eastus-vpn1"
            $SubnetName = "virtual-desktop-infrastructure-devl-subnet-application"
            $HostPoolName = $HostPoolName + "-devl"
            $avdPrefix = $avdPrefix + "D"
            $workspacesName = $workspacesName + "-devl"
        }
    }
    IN {
        $HostPoolName = $HostPoolName + "-IN"
        $avdPrefix = $avdPrefix + "IN"
        $workspacesName = $workspacesName + "-IN"
        if ($Environment -eq "Prod") {
            $ResourceGroupName = "virtual-desktop-infrastructure-prod-centralindia-rg"
            $VMNetworkResourceGroupName = "global-hosting-network-servs-prod-centralindia-network-rg"
            $VMNetworkName = "global-hosting-network-services-prod-centralindia-vpn"
            $SubnetName = "virtual-desktop-infra-prod-application-subnet"
        }
        else {
            $ResourceGroupName = "virtual-desktop-infrastructure-devl-eastus-rg"
            $VMNetworkResourceGroupName = "global-hosting-network-services-devl-eastus-network-rg"
            $VMNetworkName = "global-hosting-network-services-devl-eastus-vpn1"
            $SubnetName = "virtual-desktop-infrastructure-devl-subnet-application"
            $HostPoolName = $HostPoolName + "-devl"
            $avdPrefix = $avdPrefix + "D"
            $workspacesName = $workspacesName + "-devl"
        }
    }
}


switch ($Usertype) {
    KW {
        $HostPoolName = $HostPoolName + "-KW"
        $avdPrefix = $avdPrefix + "KW"
        $VMSize = "Standard_D2s_v5"
        $DiskSizeGB = 128
        $storagetype = "Standard_LRS"
    }
    SD {
        $HostPoolName = $HostPoolName + "-SD"
        $avdPrefix = $avdPrefix + "SD"
        $VMSize = "Standard_D2s_v5"
        $DiskSizeGB = 128
        $storagetype = "Standard_LRS"
        $ImageName = "AVD_Prod_SD_Image"
    }
    DEV {
        $HostPoolName = $HostPoolName + "-DEV"
        $avdPrefix = $avdPrefix + "DEV"
        $VMSize = "Standard_D4s_v5"
        $DiskSizeGB = 256
        $storagetype = "Premium_LRS"
    }
    ENG {
        $HostPoolName = $HostPoolName + "-ENG"
        $avdPrefix = $avdPrefix + "ENG"
        $VMSize = "Standard_D8s_v5"
        $DiskSizeGB = 256
        $storagetype = "Premium_LRS"
    }
    PRO {
        $HostPoolName = $HostPoolName + "-PRO"
        $avdPrefix = $avdPrefix + "PRO"
        $VMSize = "Standard_D8s_v5"
        $DiskSizeGB = 256
        $storagetype = "Premium_LRS"
    }
    RPA {
        $HostPoolName = "HP-W10-US-RPA"
        $avdPrefix = $avdPrefix + "RPA"
        $VMSize = "Standard_D2s_v5"
        $DiskSizeGB = 128
        $storagetype = "Standard_LRS"
        $SubnetName = "virtual-desktop-infrastructure-prod-subnet-application3"
        $IMResourceGroupName = "ioarch-wvd-poc-devl-eastus-rg"
        $ImageGalleryName = "AVD_POC_Images"
        $ImageName = "Win10_RPA_Image"
    }
    RPU {
        $HostPoolName = $HostPoolName + "-RPU"
        $avdPrefix = $avdPrefix + "PRU"
        $VMSize = "Standard_D2s_v5"
        $DiskSizeGB = 128
        $storagetype = "Standard_LRS"
        $IMResourceGroupName = "ioarch-wvd-poc-devl-eastus-rg"
        $ImageGalleryName = "AVD_POC_Images"
        $ImageName = "Win10_RPA_Image"
    }
    APP {
        $HostPoolName = "HP-APP-MS-" + $Region
        $avdPrefix = $avdPrefix + "APP"
        $VMSize = "Standard_D8s_v5"
        $DiskSizeGB = 128
        $storagetype = "Standard_LRS"
        $ImageName = "AVD_Prod_Pooled"
    }
    APPID {
        $HostPoolName = "HP-W10-US-APPID"
        $avdPrefix = $avdPrefix + "AID"
        $VMSize = "Standard_D2s_v5"
        $DiskSizeGB = 128
        $storagetype = "Standard_LRS"
        $SubnetName = "virtual-desktop-infrastructure-prod-subnet-application3"
    }
    PRNTEXCP {
        $HostPoolName = "HP-W10-" + $Region + "-PRNTEXCP"
        $avdPrefix = $avdPrefix + "PTR"
        $VMSize = "Standard_D2s_v5"
        $DiskSizeGB = 128
        $storagetype = "Standard_LRS"
    }
    CPYEXCP {
        $HostPoolName = "HP-W10-" + $Region + "-CPYEXCP"
        $avdPrefix = $avdPrefix + "CPY"
        $VMSize = "Standard_D2s_v5"
        $DiskSizeGB = 128
        $storagetype = "Standard_LRS"
    }
    APPIDUSR {
        $HostPoolName = "HP-W10-US-APPIDUSR"
        $avdPrefix = $avdPrefix + "APU"
        $VMSize = "Standard_D2s_v5"
        $DiskSizeGB = 128
        $storagetype = "Standard_LRS"
        $SubnetName = "virtual-desktop-infrastructure-prod-subnet-application4"
    }
}

$installedPackageProvider = Get-PackageProvider
if ($installedPackageProvider.Name -notcontains "NuGet") {
    Install-PackageProvider -Name NuGet -force
    Write-Output("Install powershell module NuGet")
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
if ($installedModules.Name -notcontains "Az.Compute") {
    Install-Module Az.Compute -Force -AllowClobber
}
if ($installedModules.Name -notcontains "ActiveDirectory") {
    Import-Module ActiveDirectory -Force
}

$VMLocalAdminUser = "Adminio"
$domainUser = "eadevla"
$domain = "jdnet.deere.com"
$ouPath = "OU=WVDDesktops,OU=Unit90-Corporate,OU=NorthAmerica,OU=Standard,OU=JDWorkstations,DC=jdnet,DC=deere,DC=com"
$userADGroup = Get-ADUser $requestedFor -Properties * | Select-Object UserPrincipalName
$moduleLocation = "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration.zip"
$RPAVMName = $null
Write-Output "Subscription select $SubscriptionName"
$SubscriptionId = (Get-AzSubscription -SubscriptionName $SubscriptionName).Id
Set-AzContext -SubscriptionId $SubscriptionId -TenantId "39b03722-b836-496a-85ec-850f0957ca6b"
#Connect-AzAccount -Tenant "39b03722-b836-496a-85ec-850f0957ca6b" -Subscription $SubscriptionName

$ExistingResourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
if ($ExistingResourceGroup.ResourceGroupName -notcontains $ResourceGroupName) {
    Write-Output "ResourceGroup $($ResourceGroupName) does not exist." 
}
else {
    Write-Output "ResourceGroup $($ResourceGroupName) : exists" 
    $Location = $ExistingResourceGroup.Location
                            
    $extHostPool = Get-AzWvdHostPool -Name $HostPoolName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
    if ($null -eq $extHostPool) {
        Write-Output "Hostpool $($HostPoolName) does not exist"
    }
    else {
        Write-Output "Hostpool $($HostPoolName) : exists" 
        $keyVault = Get-AzKeyVault  -VaultName $avdkeyvaultname -ResourceGroupName $avdkeyvaultRG -ErrorAction SilentlyContinue
        If ($null -eq $keyVault) {
            Write-Output "KeyVault not found"                                    
        }
        else {
            Write-Output "KeyValut $($avdkeyvaultname) : exists" 
            $VMLocalAdminSecurePassword = ConvertTo-SecureString (Get-AzKeyVaultSecret -VaultName $keyVault.Vaultname -Name "avd-ad-join" ) -AsPlainText -Force
            Write-Output "Get registration Token"
            $registrationToken = New-AzWvdRegistrationInfo -SubscriptionId $SubscriptionId -ResourceGroupName $ResourceGroupName -HostPoolName $extHostPool.Name -ExpirationTime (Get-Date).AddDays(14)
            #Get-AzWvdRegistrationInfo -HostpoolName $extHostPool.Name -ResourceGroupName $ResourceGroupName -SubscriptionId $SubscriptionId
            $registrationToken
            if ($null -eq $registrationToken) {
                $registrationToken = Update-AvdRegistrationToken -HostpoolName $extHostPool.Name -ResourceGroupName $ResourceGroupName -HoursActive 8
            }
            elseif ($registrationToken.ExpirationTime.Subtract($(Get-Date)) -le 0) {
                $registrationToken = Update-AvdRegistrationToken -HostpoolName $extHostPool.Name -ResourceGroupName $ResourceGroupName -HoursActive 8
            }
            Write-Output "$registrationToken.ExpirationTime obtained"
            $imageVersion = Get-AzGalleryImageDefinition -ResourceGroupName $IMResourceGroupName -GalleryName $ImageGalleryName -Name $ImageName
            $subnet = Get-AzVirtualNetwork -Name $VMNetworkName -ResourceGroupName $VMNetworkResourceGroupName | Get-AzVirtualNetworkSubnetConfig -Name $SubnetName
                
            $VMnames = @()
            $sessionshosts = Get-AzWvdSessionHost -HostPoolName $HostpoolName -ResourceGroupName $resourceGroupName
            foreach ($sh in $sessionshosts) {
                $VMnames += $(($sh.Name.Split('/')[1]).split('.')[0]).Replace("$avdPrefix", "")
            }
            [int]$initialnumber = ([int]$($VMnames | Measure-Object -Maximum).Maximum)
            $initialNumber++
            Write-Output "$initialnumber"

            Do {
                $VMName = $avdPrefix + "$initialNumber"
                $ComputerName = $VMName
                $nicName = "$VMName-nic"

                Write-Output "Starting $($VMName) deployment" 

                $NIC = New-AzNetworkInterface -Name $NICName -ResourceGroupName $ResourceGroupName -Location $location -SubnetId $subnet.Id
                $Credential = New-Object System.Management.Automation.PSCredential ($VMLocalAdminUser, $VMLocalAdminSecurePassword);
        
                $VirtualMachine = New-AzVMConfig -VMName $VMName -VMSize $VMSize -LicenseType "Windows_Client"
                $VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $ComputerName -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate
                $VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $NIC.Id
                $VirtualMachine = Set-AzVMOSDisk -Windows -VM $VirtualMachine -CreateOption FromImage -DiskSizeInGB $DiskSizeGB -StorageAccountType $storagetype
                $VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -Id $imageVersion.id
        
                $sessionHost = New-AzVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $VirtualMachine #-OSDiskDeleteOption Delete -NetworkInterfaceDeleteOption Delete
                $sessionHost
                            
                $initialNumber++
                $sessionHostCount--
                Write-Output "$VMName deployed"

                Write-Output "Starting Domain Join"
                $domainJoinSettings = @{
                    Name                   = "joindomain"
                    Type                   = "JsonADDomainExtension" 
                    Publisher              = "Microsoft.Compute"
                    typeHandlerVersion     = "1.3"
                    SettingString          = '{
                                                    "name": "'+ $($domain) + '",
                                                    "ouPath": "'+ $($ouPath) + '",
                                                    "user": "'+ $($domain) + '\\' + $($domainUser) + '",
                                                    "restart": "'+ $true + '",
                                                    "options": 3
                                                }'
                    ProtectedSettingString = '{ "password":"' + $(Get-AzKeyVaultSecret -VaultName $keyVault.Vaultname -Name "avd-ad-join" -AsPlainText) + '"}'
                    VMName                 = $VMName
                    ResourceGroupName      = $resourceGroupName
                    location               = $Location
                }
                Set-AzVMExtension @domainJoinSettings
                    
                Write-Output "Starting RD Agent install and setup"
                $avdDscSettings = @{
                    Name               = "Microsoft.PowerShell.DSC"
                    Type               = "DSC" 
                    Publisher          = "Microsoft.Powershell"
                    typeHandlerVersion = "2.73"
                    SettingString      = "{
                                                ""modulesUrl"":'$ModuleLocation',
                                                ""ConfigurationFunction"":""Configuration.ps1\\AddSessionHost"",
                                                ""Properties"": {
                                                    ""hostPoolName"": ""$($HostpoolName)"",
                                                    ""registrationInfoToken"": ""$($registrationToken.token)""
                                                    }
                                            }"
                    VMName             = $VMName
                    ResourceGroupName  = $resourceGroupName
                    location           = $Location
                }
                Set-AzVMExtension @avdDscSettings

                if($Usertype -eq "RPA"){
                    $RPAVMName = "AVD Machine Name: "+ $VMName
                }
                Start-Sleep -Seconds 10
                Restart-AzVM -ResourceGroupName $resourceGroupName -Name $VMName -NoWait -Confirm:$false
                #Update-AzWvdSessionHost -HostPoolName HostpoolName -Name $VMName -ResourceGroupName $resourceGroupName -AssignedUser $userADGroup.UserPrincipalName
            }
            while ($sessionHostCount -ne 0) {
                Write-Output "All Session hosts are created"
            }
            $from = "AVD-automation-noreply@johndeere.com"
            $cc = $requestedby
            $bcc = "EDSVirtualDesktopTier3@JohnDeere.com"
            $to = "$enduseremail"
            $subject = "AVD Provisioning Request for $($userADGroup.UserPrincipalName)"
            $body = @"
            <html>
            <body style="font-family:Verdana"> 
            <img src='cid:JDlogo.png'>
            <p>
            <img src='cid:greenbar.png'>
    <p>
    Hello Requestor,</p>

    </p>As per your request, a new Azure Virtual Desktop has been assigned to $($userADGroup.UserPrincipalName).
        
    </p>Attached are the reference material to setup and configure your AVD.
        
    </p>If you are using Deere asset please use <a href="http://jdsrs.deere.com/esd">JDSRS</a> and for Non-Deere asset use <a href="https://go.microsoft.com/fwlink/?linkid=2068602">Remote Desktop Client for Windows </a> / <a href="https://apps.apple.com/app/microsoft-remote-desktop/id1295203466?mt=12">Remote Desktop Client for MAC </a> to install the Microsoft Remote Desktop App Client software.
        
    <P>For any issues with AVD, Please contact Service Desk : <a href="https://johndeere.service-now.com/ep?id=kb_article&amp;sys_id=89375c0c13c32200b082bcaf3244b0fb">Service Desk Phone Number List</a>
    
    <p>Upon receiving this email, Please wait up to 30 minutes before accessing your AVD.</p>
    <P> $($RPAVMName) </p>

    <p><b>IMPORTANT!!</b><p>

    <p>For Virtual desktops which haven not been used for more than 3 days, the session will take 5 minutes to launch when you attempt to connect, avoid clicking on the desktop icon multiple times as this will corrupt the session making it unavailable for launch.<p>

    <p>Please be informed that if a Virtual Desktop has not been used for more than 30 days continuously, they are subjective to decommission on the 31st day.<p>
    
    <p>Always ensure that your Remote Desktop Client is maintained at the latest version.<p>

    <p>Ensure that you save your data on One Drive to be able to safely recover your information incase of any issues.<p>
    
    <P>Thank you!
    </p>Desktop VDI Team
    <p>
    <p>-- This email is computer generated do not reply to this email --
"@

            Send-MailMessage -From $from -To $to -Cc $cc -Bcc $bcc -Subject $subject -Body $body -BodyAsHtml -Attachments "C:\Scripts\gitfiles\AVD-PA-Scripts\New Azure Virtual Desktop User Guide.docx" -SmtpServer mail.dx.deere.com
            return 0
            
        }
    }
        
}

#<p> Feedback Form: <a href="https://forms.office.com/r/qB84MeeD6H">Here</a> </p>