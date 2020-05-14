$sn = '413356ad'
$storeName = "CA"
 
$store = New-Object System.Security.Cryptography.X509Certificates.X509Store $storeName, LocalMachine
$store.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadOnly)
 
$cert = $store.Certificates | Where-Object {$_.SerialNumber -eq $sn}
if($null -ne $cert){$true}else{$false}
 
$store.Close()
