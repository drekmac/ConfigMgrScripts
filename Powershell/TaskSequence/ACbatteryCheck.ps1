if((get-ciminstance -ClassName batterystatus -Namespace root\wmi).PowerOnline){Exit 0}else{Exit 10}
if($null -ne (Get-CimInstance -ClassName batterystatus -Namespace root\wmi -ErrorAction Ignore)){if((get-ciminstance -ClassName batterystatus -Namespace root\wmi).PowerOnline){Exit 0}else{Exit 10}}




powershell -executionpolicy bypass -Command "if($null -ne (Get-CimInstance -ClassName batterystatus -Namespace root\wmi -ErrorAction Ignore)){if((get-ciminstance -ClassName batterystatus -Namespace root\wmi).PowerOnline){Exit 0}else{Exit 10}}"