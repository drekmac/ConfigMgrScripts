Param
(
    [Parameter(Mandatory = $true,
    HelpMessage = "AdvertisementID" )]
    [String]$AdID,
    [Parameter(Mandatory = $true,
    HelpMessage = "Computer Name")]
    [String]$Name,
    [Parameter(Mandatory = $true,
    HelpMessage = "Task ID")]
    [String]$TaskID,
    [Parameter(Mandatory = $true,
    HelpMessage = "Task Name")]
    [String]$TaskName,
    [Parameter(Mandatory = $true)]
    [string]$path
)
filter timestamp {"$(Get-Date -Format "yyyy-MM-dd_HH.mm.ss"): $_"}
########################################## 
$localpath = 'C:\ProgramData\ORG' #Change ORG to your organization's name, or the whole thing to use a different log path
##########################################
$filepath = "$path\OSUpgradeTS.log"
$script = $MyInvocation.MyCommand.Name
"$script Started" | timestamp | Out-File $filepath -Append

try {
    [datetime]$date = get-date -UFormat "%D %r"
    If(!(Test-Path $localpath)){
        New-Item -ItemType Directory -Force -Path $localpath
    }
    If(!(Test-Path "$localpath\Logs")){
        New-Item -ItemType Directory -Force -Path "$localpath\Logs"
    }
    $regpath = 'HKLM:\SOFTWARE\CCM'
    $OSbuild = (Get-CimInstance -ClassName Win32_OperatingSystem -Namespace root/cimv2).BuildNumber
    if((Test-Path -LiteralPath "HKLM:\SOFTWARE\CCM") -ne $true) {
        $regmain = New-Item $regpath -force -ea SilentlyContinue
        $regmain.Name + " created" | timestamp | Out-File $filepath -Append
    }else {
        "HKEY_LOCAL_MACHINE\SOFTWARE\CCM already exists" | timestamp | Out-File $filepath -Append
    }
    New-ItemProperty -LiteralPath $regpath -Name 'UPGRADEAdvertisementID' -Value $AdID -PropertyType String -Force -ErrorAction SilentlyContinue
    New-ItemProperty -LiteralPath $regpath -Name 'UPGRADEMachineName' -Value $Name -PropertyType String -Force -ErrorAction SilentlyContinue
    New-ItemProperty -LiteralPath $regpath -Name 'UPGRADETaskSequenceID' -Value $TaskID -PropertyType String -Force -ErrorAction SilentlyContinue
    New-ItemProperty -LiteralPath $regpath -Name 'UPGRADETSPackageName' -Value $TaskName -PropertyType String -Force -ErrorAction SilentlyContinue
    New-ItemProperty -LiteralPath $regpath -Name 'UPGRADEInstallDateStart' -Value $date -PropertyType String -Force -ErrorAction SilentlyContinue
    New-ItemProperty -LiteralPath $regpath -Name 'UPGRADEOSBuildStart' -Value $OSbuild -PropertyType String -Force -ErrorAction SilentlyContinue
    "UPGRADEAdvertisementID=$AdID,UPGRADEMachineName=$name,UPGRADETaskSequenceID=$taskid,UPGRADETSPackageName=$taskname,UPGRADEInstallDateStart=$date,UPGRADEOSBuildStart=$osbuild written to $regpath" | timestamp | Out-File $filepath -Append
}
catch {
    "Script failed" | timestamp | Out-File $filepath -Append
}