Param
(
    [Parameter(Mandatory = $true,
    HelpMessage = "Size to set Cache to" )]
    [Int]$Size,
    [Parameter(Mandatory = $true)]
    [string]$path
)
filter timestamp {"$(Get-Date -Format "yyyy-MM-dd_HH.mm.ss"): $_"}
$filepath = "$path\OSUpgradeTS.log"
$script = $MyInvocation.MyCommand.Name
"$script Started" | timestamp | Out-File $filepath -Append

$Cache = Get-wmiobject -Namespace 'ROOT\CCM\SoftMgmtAgent' -Class CacheConfig
if($cache.Size -lt $Size){
    $Cache.Size = $Size
    $Cache.Put()
    Restart-Service -Name CcmExec
    "Cache was " + $cache.Size + " MB, set to $size MB" | timestamp | Out-File $filepath -Append
}
else {
    "Cache size " + $Cache.Size + " MB, already at or above $Size MB" | timestamp | Out-File $filepath -Append
}