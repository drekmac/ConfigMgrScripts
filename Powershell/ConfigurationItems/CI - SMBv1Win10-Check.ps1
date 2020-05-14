#Windows 10 only, checks if SMBv1 is enabled
$smb = (Get-WindowsOptionalFeature -online -featurename SMB1Protocol).State
if($smb -eq "Enabled"){$true}
if($smb -eq "Disabled"){$false}