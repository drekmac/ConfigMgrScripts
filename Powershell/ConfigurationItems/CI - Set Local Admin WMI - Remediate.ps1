## PowerShell to Populate Local Admin Class ##
#Clear-Host
    try{
    #*****************************************************
    #  Create Log File
    #*****************************************************
    $log = "C:\ProgramData\Mercy\Logs\Admin_Accounts.log"
    If (Test-Path $log) {
        Remove-Item -Path $log -Force
    }

    #*****************************************************
    #  HWINV_LocalAdmins Class Creation
    #*****************************************************
    $WMIClassName = "HWINV_LocalAdmins"
    $WMINameSpace = "root\cimv2"
    #Delete the class if it exists; if it doesn't don't stop because of the error
    Remove-WmiObject -Class $WMIClassName -Namespace $WMINameSpace -ErrorAction SilentlyContinue
    
    #Create the new Class 
    $NewClass = New-Object System.Management.ManagementClass($WMINameSpace, [String]::Empty, $null); 
    $NewClass["__CLASS"] = $WMIClassName; 
    $NewClass.Qualifiers.Add("Static", $true)
    
    $NewClass.Properties.Add("Member",[System.Management.CimType]::String, $false)
    $NewClass.Properties.Add("Date",[System.Management.CimType]::String, $false)
    $NewClass.Properties["Member"].Qualifiers.Add("Key", $true)
        
    $NewClass.Put()
    
    #*****************************************************
    #  Script to Populate the HWINV_LocalAdmins class
    #*****************************************************
    
    # Use the universal SID to get the Administrator group information regardless of language:
    $AdminGroup = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-32-544")
    [String]$AdminGroupName = $AdminGroup.Translate([System.Security.Principal.NTAccount]).Value
    # Remove the 'domain' from the group name:
    $AdminGroupName = $AdminGroupName.Substring($AdminGroupName.IndexOf("\")+1)
    
    # Get the local admins:
    $LocalAdmins = net localgroup $AdminGroupName | Where-Object {$_} | Select-Object -Skip 4 -ErrorAction Stop # Assuming all languages will return the same number of header lines

    #Get Date:
    #$psdate = get-date
    $Date = get-date -Format yyyy-MM-dd-hh:mm
    
    # Because $LocalAdmins is an array and the last item/index is the "command completed successfully" message we'll use a for loop and not do anything with the last item:
    for ($i=0; $i -lt $LocalAdmins.Count-1; $i++) {
        [String]$CurAdmin = $LocalAdmins[$i]
        if ($CurAdmin -notmatch "\\") { # escape the backslash so the match doesn't throw an error
            # Add the computername as the account domain since no domain was given:
            $CurAdmin = "$($env:ComputerName)\$CurAdmin"
    
            # Because the Administrator account is listed without the domain it will fall into this loop; we want to ignore the Administrator account
            # but want to account for any language; so we'll get the account's SID and do a regex compare to ensure we don't include the Admin:
            $CurAdminObj = New-Object System.Security.Principal.NTAccount($CurAdmin)
            $CurAdminSID = $CurAdminObj.Translate([System.Security.Principal.SecurityIdentifier]) | Select-Object -ExpandProperty Value
    
            if ($CurAdminSID -notmatch "S-1-5-21-\d+-\d+-\d+-500") { # The local Admin account SID always follows this pattern. Note: the SID is variable length hence "\d+" rather than "\d{n}"
                # The account is not the local Admin account so we'll add the account to the WMI class:
                Set-WMIInstance -Class $WMIClassName -Namespace $WMINameSpace -argument @{Member=$CurAdmin;Date=$Date} -ErrorAction Stop
                $CurAdmin | Out-File $log -Append
            }
        }
        else {
            # The account already has the domain included so just add it directly to the WMI class:
            Set-WMIInstance -Class $WMIClassName -Namespace $WMINameSpace -argument @{Member=$CurAdmin;Date=$Date} -ErrorAction Stop
            $CurAdmin | Out-File $log -Append
        }
    } # End For Loop
    #get-ciminstance -ClassName "HWINV_LocalAdmins" | Select-Object Member
    # End Script
    return 0
}
catch{
    return 1
}