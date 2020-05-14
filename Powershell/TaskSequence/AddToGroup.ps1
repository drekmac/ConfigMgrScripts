# Script to add the computername on which the script is executed on to specified groups.
# Example Command line with Powershell.exe -NoProfile -ExecutionPolicy Bypass –File AddToGroups.Ps1 -group “group”
Param
(
    [Parameter(Mandatory = $true)]
    [string]$Group,
    [Parameter(Mandatory = $true)]
    [string]$path
)
filter timestamp {"$(Get-Date -Format "yyyy-MM-dd_HH.mm.ss"): $_"}
$filepath = "$path\OSUpgradeTS.log"
$script = $MyInvocation.MyCommand.Name
"$script Started" | timestamp | Out-File $filepath -Append

try {
    "Variable dump for troubleshooting - Computer= $env:COMPUTERNAME Group= $Group" | timestamp | Out-File $filepath -Append
    "Searching for $env:COMPUTERNAME in Active Directory" | timestamp | Out-File $filepath -Append
    $ComputerDn = ([ADSISEARCHER]"sAMAccountName=$($env:COMPUTERNAME)$").FindOne().Path
    "Results: $ComputerDn" | timestamp | Out-File $filepath -Append
    "Searching for $Group in Active Directory" | timestamp | Out-File $filepath -Append
    $GroupDn = ([ADSISEARCHER]"sAMAccountName=$($Group)").FindOne().Path
    "Results: $GroupDn" | timestamp | Out-File $filepath -Append
    $GroupDnObj = [ADSI]"$GroupDn"

    if(!$GroupDnObj.IsMember($ComputerDn)) {
        $GroupDnObj.Add($ComputerDn)
        "Added $env:COMPUTERNAME to $group" | timestamp | Out-File $filepath -Append
    }
    else{
        "Already a member of $Group" | timestamp | Out-File $filepath -Append
    }
}
catch {
    $_.Exception.Message | timestamp | Out-File $filepath -Append
}
