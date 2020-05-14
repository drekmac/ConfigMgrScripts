$path = "\\Wdc-vsdsps1p01\sms_ps1\inboxes\auth\dataldr.box\BADMIFS\DeltaMismatch"
$list = (Get-ChildItem $path).Name
$date = Get-Date -Format 'yyyy-MM-dd_HH-mm'
foreach($file in $list){
    $line = get-content "$path\$file" | Where-Object {$_ -match '//KeyAttribute<NetBIOS Name>'} | Select-Object -Index 0
    $comp = $line.Substring(28) -replace '[\W]', ''
    New-Object PSObject -Property @{
        ComputerName = $comp
        Line = $line
        Mif = $file
    } | Export-Csv ".\ComputerNamesFromMif$date.csv" -NoTypeInformation -Append
    
}