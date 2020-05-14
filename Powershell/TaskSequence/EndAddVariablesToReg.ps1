Param
(    
    [Parameter(Mandatory = $true)]
    [string]$path
)
filter timestamp {"$(Get-Date -Format "yyyy-MM-dd_HH.mm.ss"): $_"}
$filepath = "$path\OSUpgradeTS.log"
$script = $MyInvocation.MyCommand.Name
"$script Started" | timestamp | Out-File $filepath -Append

try {
    [datetime]$StartTime = Get-ItemPropertyValue -LiteralPath 'HKLM:\SOFTWARE\CCM' -Name 'UPGRADEInstallDateStart'
    [datetime]$date = get-date -UFormat "%D %r"
    $difference = ($date - $StartTime).TotalMinutes
    $OSbuild = (Get-CimInstance -ClassName Win32_OperatingSystem -Namespace root/cimv2).BuildNumber
    $regpath = 'HKLM:\SOFTWARE\CCM'
    New-ItemProperty -LiteralPath $regpath -Name 'UPGRADEInstallDateEnd' -Value $date -PropertyType String -Force -ErrorAction SilentlyContinue
    New-ItemProperty -LiteralPath $regpath -Name 'UPGRADEDurationMinutes' -Value $difference -PropertyType String -Force -ErrorAction SilentlyContinue
    New-ItemProperty -LiteralPath $regpath -Name 'UPGRADEOSBuildEnd' -Value $OSbuild -PropertyType String -Force -ErrorAction SilentlyContinue  
    "UPGRADEInstallDateEnd=$date,UPGRADEDurationMinutes=$difference,UPGRADEOSBuildEnd=$OSbuild written to $regpath" | timestamp | Out-File $filepath -Append  
}
catch {
    "Script failed" | timestamp | Out-File $filepath -Append
}
