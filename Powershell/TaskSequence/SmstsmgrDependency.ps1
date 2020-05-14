Param
(
    [Parameter(Mandatory = $true)]
    [string]$path
)
#This was for a one off thing, probably will never be needed again.
filter timestamp {"$(Get-Date -Format "yyyy-MM-dd_HH.mm.ss"): $_"}
$filepath = "$path\OSUpgradeTS.log"
$script = $MyInvocation.MyCommand.Name
"$script Started" | timestamp | Out-File $filepath -Append

$dependency = (get-service smstsmgr).ServicesDependedOn.Name
try {
    If($dependency -contains 'smsexec'){
        "Smstsmgr dependency: $dependency contains smsexec, which has to be removed" | timestamp | Out-File $filepath -Append
        sc.exe config "smstsmgr" depend="winmgmt"
        (get-service smstsmgr).ServicesDependedOn.Name + " is the current dependency." | timestamp | Out-File $filepath -Append
    }
    else{
        "Smstsmgr does not depend on smsexec, no change needed." | timestamp | Out-File $filepath -Append
    }
}
catch{
    $_.Exception.Message | timestamp | Out-File $filepath -Append
}