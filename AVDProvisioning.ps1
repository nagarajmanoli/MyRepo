[CmdletBinding()]
param (
    
    [Parameter()]
        [ValidateSet("US","EU","IN")]
        [String] $Region,
    [Parameter()] 
        [ValidateSet("KW", "SD", "DEV", "ENG", "RPA", "RPU", "PRO", "APP", "APPID", "PRNTEXCP", "CPYEXCP", "APPIDUSR")]
        [String] $Usertype,
    [Parameter()] 
        [ValidateSet("Prod","Devl")]
        [String] $Environment = "Devl",
    [Parameter()] 
        [ValidateSet("Persistent","Pooled")]
        [String] $VMHPType = "Persistent",
    [Parameter()] [int] $sessionHostCount = 1,
    [Parameter()] [switch] $Hostpool = $false
)

$HostPoolName = "HP-W10"
$workspacesName = "WS-W10"
$avdPrefix = "AZW10"

$CustomRdpProp = 'drivestoredirect:s:;audiomode:i:0;videoplaybackmode:i:1;redirectclipboard:i:0;redirectprinters:i:0;devicestoredirect:s:;redirectcomports:i:0;redirectsmartcards:i:0;usbdevicestoredirect:s:;enablecredsspsupport:i:1;use multimon:i:1;autoreconnection enabled:i:1;bandwidthautodetect:i:1;networkautodetect:i:1;compression:i:1;audiocapturemode:i:1;encode redirected video capture:i:1;redirected video capture encoding quality:i:1;camerastoredirect:s:*'


switch ($Environment) {
    Prod { 
        $SubscriptionName = "azure-global-hosting-network-services-prod"
        $avdkeyvaultname = "AVDKeyValult-Prod"
        $avdkeyvaultRG = "virtual-desktop-infrastructure-prod-eastus-rg"
        $logAnalyticsWorkspacename = "AVD-Log-Analytics-Workspace-EUS"
        $WSResourceGroupName = "virtual-desktop-infrastructure-prod-eastus-rg"
        $IMResourceGroupName = "virtual-desktop-infrastructure-prod-eastus-rg"
        $ImageGalleryName = "AVD_Prod_Image_Gallery"
        $ImageName = "AVD_Prod_KW_Image"
     }
    Devl {
        $SubscriptionName = "azure-global-hosting-network-services-devl"
        $avdkeyvaultname = "avd-vault-devl"
        $avdkeyvaultRG = "ioarch-wvd-poc-devl-eastus-rg"
        $logAnalyticsWorkspacename = "wvd-log-workspace"
        $WSResourceGroupName = "ioarch-wvd-poc-devl-eastus-rg"
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
        $hostpooltype = 'Personal'
        $LoadBalancerType = "Persistent"
     }
    Pooled {
        $HostPoolName = $HostPoolName + "-MS"
        $workspacesName = $workspacesName + "-MS"
        $avdPrefix = $avdPrefix + "M"
        $hostpooltype = "Pooled"
        $LoadBalancerType = "Depth-first"
    }
}
switch ($Region) {
    US {
        $HostPoolName = $HostPoolName + "-US"
        $avdPrefix = $avdPrefix + "US"
        $workspacesName = $workspacesName + "-US"
        $HPLocation = "East US"
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
        $HPLocation = "West Europe"
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
        $HPLocation = "West Europe"
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
        $HostPoolName = "HP-W10-"+ $Region + "-PRNTEXCP"
        $avdPrefix = $avdPrefix + "PTR"
        $VMSize = "Standard_D2s_v5"
        $DiskSizeGB = 128
        $storagetype = "Standard_LRS"
        $CustomRdpProp = "drivestoredirect:s:;audiomode:i:0;videoplaybackmode:i:1;redirectclipboard:i:0;redirectprinters:i:1;devicestoredirect:s:;redirectcomports:i:0;redirectsmartcards:i:0;usbdevicestoredirect:s:;enablecredsspsupport:i:1;use multimon:i:1;autoreconnection enabled:i:1;bandwidthautodetect:i:1;networkautodetect:i:1;compression:i:1;audiocapturemode:i:1;encode redirected video capture:i:1;redirected video capture encoding quality:i:1;camerastoredirect:s:*"
    }
    CPYEXCP {
        $HostPoolName = "HP-W10-"+ $Region + "-CPYEXCP"
        $avdPrefix = $avdPrefix + "CPY"
        $VMSize = "Standard_D2s_v5"
        $DiskSizeGB = 128
        $storagetype = "Standard_LRS"        
        $CustomRdpProp ="drivestoredirect:s:;audiomode:i:0;videoplaybackmode:i:1;redirectclipboard:i:1;redirectprinters:i:0;devicestoredirect:s:;redirectcomports:i:0;redirectsmartcards:i:0;usbdevicestoredirect:s:;enablecredsspsupport:i:1;use multimon:i:1;autoreconnection enabled:i:1;bandwidthautodetect:i:1;networkautodetect:i:1;compression:i:1;audiocapturemode:i:1;encode redirected video capture:i:1;redirected video capture encoding quality:i:1;camerastoredirect:s:*"
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
    Write-Output("Install powershell module Az Accounts")
}
if ($installedModules.Name -notcontains "Az.Resources") {
    Install-Module Az.Resources -Force -AllowClobber
    Write-Output("Install powershell module Az Resources")
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


$VMLocalAdminUser = "Adminio"
$domainUser = "eadevla"
$domain = "jdnet.deere.com"
$ouPath = "OU=WVDDesktops,OU=Unit90-Corporate,OU=NorthAmerica,OU=Standard,OU=JDWorkstations,DC=jdnet,DC=deere,DC=com"

$moduleLocation = "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration.zip"

Write-Output "Subscription select $SubscriptionName"
$SubscriptionId = (Get-AzSubscription -SubscriptionName $SubscriptionName).Id
Set-AzContext -SubscriptionId $SubscriptionId -TenantId "39b03722-b836-496a-85ec-850f0957ca6b"
#Connect-AzAccount -Tenant "39b03722-b836-496a-85ec-850f0957ca6b" -Subscription $SubscriptionName

if($Hostpool){
    $initialNumber = 0
    Write-Output "Entering Hostpool creation"
    $ExistingResourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
    if ($ExistingResourceGroup.ResourceGroupName -notcontains $ResourceGroupName) {
        Write-Output "ResourceGroup $($ResourceGroupName) does not exist." 
    }
    else {
        Write-Output "ResourceGroup $($ResourceGroupName) : exists" 
        $Location = $ExistingResourceGroup.Location
        
        $workspace = Get-AzWvdWorkspace -Name $workspacesName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
        if($null -eq $workspace){
            Write-Output "Worskapce $($workspacesName) does not exist. Creating Workspace"
            New-AzWvdWorkspace  -ResourceGroupName $ResourceGroupName `
                            -Name "$workspacesName" `
                            -Location $HPLocation `
                            -FriendlyName "Knowledge Worker - $Region" `
                            -ApplicationGroupReference $null `
                            -Description "$workspacesName"
        }
        Write-Output "Worskapce $($workspacesName) : exist. Creating Hostpool"
        $extHostPool = Get-AzWvdHostPool -Name $HostPoolName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
        if ($null -ne $extHostPool) {
            Write-Output "Hostpool $($HostPoolName) exist will not create new"
        }
        else {
            New-AzWvdHostPool   -Name $HostPoolName `
                                -ResourceGroupName $ResourceGroupName `
                                -Location $HPLocation `
                                -FriendlyName "$HostPoolName" `
                                -HostPoolType "$hostpooltype" `
                                -LoadBalancerType "$LoadBalancerType" `
                                -RegistrationTokenOperation 'Update' `
                                -ExpirationTime $((get-date).ToUniversalTime().AddDays(2).ToString('yyyy-MM-ddTHH:mm:ss.fffffffZ')) `
                                -Description "$HostPoolName" `
                                -VMTemplate $null `
                                -CustomRdpProperty $CustomRdpProp `
                                -MaxSessionLimit '9999' `
                                -PreferredAppGroupType 'Desktop' `
                                -ValidationEnvironment:$false
                            
            $newHostPool = Get-AzWvdHostPool -Name $HostPoolName -ResourceGroupName $ResourceGroupName
    
            New-AzWvdApplicationGroup   -Name "$($HostPoolName)-DAG" `
                                        -ResourceGroupName $ResourceGroupName `
                                        -ApplicationGroupType 'Desktop' `
                                        -HostPoolArmPath $newHostPool.id `
                                        -Location $HPLocation
        
            $DAG = Get-AzWvdApplicationGroup -Name "$($HostPoolName)-DAG" -ResourceGroupName $ResourceGroupName
        
            Register-AzWvdApplicationGroup  -ResourceGroupName $ResourceGroupName `
                                            -WorkspaceName "$($workspacesName)" `
                                            -ApplicationGroupPath $DAG.id
            
            <#
            $VMnames = @()
            $sessionshosts = Get-AzWvdSessionHost -HostPoolName $HostpoolName -ResourceGroupName $resourceGroupName
            foreach($sh in $sessionshosts){
                $VMnames += $(($sh.Name.Split('/')[1]).split('.')[0]).Replace("$avdPrefix","")
            }
            [int]$initialnumber = ([int]$($VMnames | Measure-Object -Maximum).Maximum)
            if($initialNumber -ne 0){
                $initialNumber ++
            }
            #>
            Write-Output "Initial number $initialnumber"
        }            
        
    
        $keyVault = Get-AzKeyVault  -VaultName $avdkeyvaultname `
                                    -ResourceGroupName $avdkeyvaultRG
        
        If($null -eq $keyVault){
            Write-Output "KeyVault not found"                                    
        }
        else {
            $VMLocalAdminSecurePassword = ConvertTo-SecureString (Get-AzKeyVaultSecret -VaultName $keyVault.Vaultname -Name "avd-ad-join" ) -AsPlainText -Force
        }
    
        $registrationToken = Get-AzWvdRegistrationInfo -HostpoolName $HostPoolName -ResourceGroupName $ResourceGroupName
        $imageVersion = Get-AzGalleryImageDefinition -ResourceGroupName $IMResourceGroupName -GalleryName $ImageGalleryName -Name $ImageName
        $subnet = Get-AzVirtualNetwork -Name $VMNetworkName -ResourceGroupName $VMNetworkResourceGroupName | Get-AzVirtualNetworkSubnetConfig -Name $SubnetName
    
        Do {
            $VMName = $avdPrefix+"$initialNumber"
            $ComputerName = $VMName
            $nicName = "$vmName-nic"
            $NIC = New-AzNetworkInterface -Name $NICName -ResourceGroupName $ResourceGroupName -Location $location -SubnetId $subnet.Id
            $Credential = New-Object System.Management.Automation.PSCredential ($VMLocalAdminUser, $VMLocalAdminSecurePassword);
        
            $VirtualMachine = New-AzVMConfig -VMName $VMName -VMSize $VMSize -LicenseType "Windows_Client"
            $VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $ComputerName -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate
            $VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $NIC.Id
            $VirtualMachine = Set-AzVMOSDisk -Windows -VM $VirtualMachine -CreateOption FromImage -DiskSizeInGB $DiskSizeGB -StorageAccountType $storagetype
            $VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -Id $imageVersion.id
        
            $sessionHost = New-AzVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $VirtualMachine # -OSDiskDeleteOption Delete -NetworkInterfaceDeleteOption Delete
        
            $initialNumber++
            $sessionHostCount--
            Write-Output "$VMName deployed"
    
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
                ProtectedSettingString = '{
                    "password":"' + $(Get-AzKeyVaultSecret -VaultName $keyVault.Vaultname -Name "avd-ad-join" -AsPlainText) + '"}'
                VMName                 = $VMName
                ResourceGroupName      = $resourceGroupName
                location               = $Location
            }
            Set-AzVMExtension @domainJoinSettings
        
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
            
        }
        while ($sessionHostCount -ne 0) {
            Write-Verbose "Session hosts are created"
        }
           
        
        
        $laws = Get-AzOperationalInsightsWorkspace -ResourceGroupName $WSResourceGroupName -Name $logAnalyticsWorkspacename 
        $diagnosticsParameters = @{
            Name = "AVD-Diagnostics"
            ResourceId = $newHostpool.id
            WorkspaceId = $laws.ResourceId
            Enabled = $true
            Category = @("Checkpoint","Error","Management","Connection","HostRegistration")
        }
        
        $avdDiagnotics = Set-AzDiagnosticSetting  @diagnosticsParameters
        $avdDiagnotics
        #>
    }
}
else {
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
                #$registrationToken = New-AzWvdRegistrationInfo -SubscriptionId $SubscriptionId -ResourceGroupName $ResourceGroupName -HostPoolName $extHostPool.Name -ExpirationTime (Get-Date).AddDays(14)
                $registrationToken = Get-AzWvdRegistrationInfo -HostpoolName $extHostPool.Name -ResourceGroupName $ResourceGroupName -SubscriptionId $SubscriptionId
                $registrationToken
                if($null -eq $registrationToken){
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
                foreach($sh in $sessionshosts){
                    $VMnames += $(($sh.Name.Split('/')[1]).split('.')[0]).Replace("$avdPrefix","")
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
                }
                while ($sessionHostCount -ne 0) {
                    Write-Output "All Session hosts are created"
                }
            }
        }
        
    }
}