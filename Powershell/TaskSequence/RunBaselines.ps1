Param
(    
    [Parameter(Mandatory = $true)]
    [string]$path
)
#Runs a baseline called "Cleanup Disk Space" and will do nothing if a baseline with that name doesn't exist
filter timestamp {"$(Get-Date -Format "yyyy-MM-dd_HH.mm.ss"): $_"}
$filepath = "$path\OSUpgradeTS.log"
$script = $MyInvocation.MyCommand.Name
"$script Started" | timestamp | Out-File $filepath -Append

$baselines = $baselines = get-ciminstance -query "Select * from SMS_DesiredConfiguration where displayname = 'Cleanup Disk Space'" -Namespace root\ccm\dcm
$baselines | ForEach-Object {
    ([wmiclass]"root\ccm\dcm:SMS_DesiredConfiguration").TriggerEvaluation($_.Name, $_.Version)
    $_.DisplayName + " ran" | timestamp | Out-File $filepath -Append
}