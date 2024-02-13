

# MSIX App Attach - Create VHD

$Application = 'vlc'

New-VHD 
     -SizeBytes 512MB `
     -Path c:\AppAttach\$Application.vhdx`
     -Dynamic `
     -Confirm:$true

$vhdObject = Mount-VHD c:\AppAttach\$Application.vhd `
     -Passthru

$disk = Initialize-Disk `
     -Passthru
     -Number $vhdObject.Number

$partition = New-Partition `
     -AssignDriveLetter `
     -UseMaximumSize `
     -DiskNumber $disk.Number

Format-Volume
     -FileSystem NTFS `
     -Confirm:$false `
     -DriveLetter $partition.DriveLetter `
     -Force

