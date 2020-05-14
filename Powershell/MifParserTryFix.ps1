$path = "\\Wdc-vsdsps1p01\sms_ps1\inboxes\auth\dataldr.box\BADMIFS\DeltaMismatch"
$list = (Get-ChildItem $path).Name
$date = Get-Date -Format 'yyyy-MM-dd_HH-mm'
foreach($file in $list){
    $testcon = $null
    $success = $null
    $line = get-content "$path\$file" | Where-Object {$_ -match '//KeyAttribute<NetBIOS Name>'} | Select-Object -Index 0
    $comp = $line.Substring(28) -replace '[\W]', ''
    $ping = Test-Connection $comp -Count 1 -TimeToLive 255 -Quiet
    if($ping){
        $testcon = $true
        try{            
            $session = New-CimSession -ComputerName $comp -ErrorAction Stop
            Get-CimInstance -CimSession $session -ClassName InventoryActionStatus -Namespace "root\ccm\invagt" | Where-Object InventoryActionID -eq '{00000000-0000-0000-0000-000000000001}' | remove-ciminstance -ErrorAction Ignore
            Invoke-CIMMethod -CimSession $session -Namespace root\ccm -ClassName SMS_CLIENT -MethodName TriggerSchedule -Arguments @{sScheduleID = '{00000000-0000-0000-0000-000000000001}'} -ErrorAction Stop
            $success = "True"
            if($session){
                Remove-CimSession $session
            }
        }
        catch{
            $success = $error[0] | Select-Object Exception
        }
    }else{
        $testcon = $false
    }
    New-Object PSObject -Property @{
        ComputerName = $comp
        Ping = $testcon
        Line = $line
        Mif = $file
        Inv_Triggered = $success
    } | Export-Csv ".\ComputerNamesFromMif$date.csv" -NoTypeInformation -Append    
}