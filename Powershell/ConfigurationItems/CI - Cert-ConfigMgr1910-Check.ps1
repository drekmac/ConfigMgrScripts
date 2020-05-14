#Checks if the certificate used to sign the ConfigMgr Powershell module is trusted
$sn = '33000001519e8d8f4071a30e41000000000151'
$storeName = "TrustedPublisher"
 
$store = New-Object System.Security.Cryptography.X509Certificates.X509Store $storeName, LocalMachine
$store.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadOnly)
 
$cert = $store.Certificates | Where-Object {$_.SerialNumber -eq $sn}
if($null -ne $cert){$true}else{$false}
 
$store.Close()
