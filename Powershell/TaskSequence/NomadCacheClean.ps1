Param
(
    [Parameter(Mandatory = $true)]
    [int]$Days,
    [Parameter(Mandatory = $true)]
    [string]$path
)
filter timestamp {"$(Get-Date -Format "yyyy-MM-dd_HH.mm.ss"): $_"}
$filepath = "$path\OSUpgradeTS.log"
$script = $MyInvocation.MyCommand.Name
"$script Started" | timestamp | Out-File $filepath -Append
try {
    $1eClient = 'C:\Program Files\1E\Client\Extensibility\NomadBranch'
    $nomad6 = 'C:\Program Files\1E\NomadBranch'
    if(Test-Path $1eClient){
        &"$1eClient\CacheCleaner.exe" "-MaxCacheAge=$Days"
        "1E client found, cleaning older than $Days days" | timestamp | Out-File $filepath -Append
    }
    elseif(Test-Path $nomad6){
        &"$nomad6\CacheCleaner.exe" "-MaxCacheAge=$Days"
        "Nomad 6 found, cleaning older than $Days days" | timestamp | Out-File $filepath -Append
    }
    else {
        "1E/Nomad not found" | timestamp | Out-File $filepath -Append
    }
}
catch {
    "Script failed" | timestamp | Out-File $filepath -Append
}
