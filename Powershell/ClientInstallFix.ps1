$test = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\DefaultMediaCost' -Name Ethernet
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\DefaultMediaCost' -Name Ethernet -Value 2
#\\itsys-sccm.ad.siu.edu\Client\ccmsetup.exe /mp:itsys-sccmmp 