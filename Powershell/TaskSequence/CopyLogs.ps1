Param
(
    [Parameter(Mandatory = $true)]
    [string]$path,
    [Parameter(Mandatory = $true)]
    [string]$localpath,
    [Parameter(Mandatory = $true)]
    [string]$smspath,
    [Parameter(Mandatory = $true)]
    [string]$name
)
filter timestamp {"$(Get-Date -Format "yyyy-MM-dd_HH.mm.ss"): $_"}

$filepath = "$localpath\OSUpgradeTS.log"

$script = $MyInvocation.MyCommand.Name
"$script Started" | timestamp | Out-File $filepath -Append

If(!(Test-Path "$path")){
    $basepath = $path -replace $name
    New-Item -Path $basepath -Name $Name -ItemType Directory
    "Created $path" | timestamp | Out-File $filepath -Append
}
else {
    "Path already exists - $path" | timestamp | Out-File $filepath -Append
}
Copy-Item $filepath -Destination $path -Force
Copy-Item -Path "$smspath\*" -Destination $path -Force