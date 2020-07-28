#requires -Module ActiveDirectory
Import-Module (Join-Path $(Split-Path $env:SMS_ADMIN_UI_PATH) ConfigurationManager.psd1)
 
 
Function Remove-DisabledADComputersFromSCCM {
    <#
    .Synopsis
        This script will check to see if disabled and deleted computers from Active Directory are still enabled in System Center Configuration Manager.
        For updated help and examples refer to -Online version.
  
 
    .DESCRIPTION
        This script will check to see if disabled and deleted computers from Active Directory are still enabled in System Center Configuration Manager.
        For updated help and examples refer to -Online version.
 
 
    .NOTES  
        Name: Remove-DisabledADComputersFromSCCM
        Author: The Sysadmin Channel
        Version: 1.0
        DateCreated: 2018-Aug-5
        DateUpdated: 2018-Aug-5
 
    .LINK
        <a class="vglnk" href="https://thesysadminchannel.com/remove-disabled-active-directory-computers-sccm-powershell/" rel="nofollow"><span>https</span><span>://</span><span>thesysadminchannel</span><span>.</span><span>com</span><span>/</span><span>remove</span><span>-</span><span>disabled</span><span>-</span><span>active</span><span>-</span><span>directory</span><span>-</span><span>computers</span><span>-</span><span>sccm</span><span>-</span><span>powershell</span><span>/</span></a> -
 
 
    .EXAMPLE
        For updated help and examples refer to -Online version.
 
    #>
 
    [CmdletBinding()]
    param(
        [Parameter()]
 
        [switch]  $DeleteComputers
    )
 
 
    BEGIN {
        #Declaring All Empty Arrays.
        $SearchRoots             = @()
        $SearchRootArray         = @()
        $DomainControllerList    = @()
        $All_ADComputers         = @()
        $RemoveComputersFromSCCM = @()
         
        # =======================================
        #Manually Enter SCCM Information
        # SCCM Site Code (3-digit code) [string]
        #$CMSiteCode = "PAC"
 
        # SCCM Primary Server (<a class="vglnk" href="http://server.domain.com" rel="nofollow"><span>server</span><span>.</span><span>domain</span><span>.</span><span>com</span></a>) [string]
        #$CMPrimaryServer = "<a class="vglnk" href="http://PAC-SCCM01.ad.thesysadminchannel.com" rel="nofollow"><span>PAC</span><span>-</span><span>SCCM01</span><span>.</span><span>ad</span><span>.</span><span>thesysadminchannel</span><span>.</span><span>com</span></a>"
 
 
        # ============================================
        # Automatically Gather SCCM Information.
        # SCCM Site Code (3-digit code)
        $CMSiteCode = Get-PSDrive -PSProvider CMSITE | select -ExpandProperty Name
 
        # SCCM Primary Server.
        $CMPrimaryServer = Get-PSDrive -PSProvider CMSITE | select -ExpandProperty Root
 
         
        # Collection name to clean up (typically 'All Systems' or 'All Workstations') [string]
        $CMCollection = "All Systems"
    }
 
    PROCESS {
        try {
            #Query the SCCM Server to get the System Discovery Agent. This will pull a list of Domains currently in use by SCCM.
            $Query = Get-WmiObject -Namespace root\sms\site_$CMSiteCode -ComputerName $CMPrimaryServer -Class SMS_SCI_Component -Filter "ComponentName='SMS_AD_SYSTEM_DISCOVERY_AGENT'" -ErrorAction Stop
            $Query.PropLists.Values | Where-Object {$_ -like "LDAP://*"} | ForEach-Object {$SearchRoots += $_.Replace("LDAP://","")}
 
            foreach ($Root in $SearchRoots) {$Position = $Root.IndexOf("DC="); $SearchRootArray += $Root.Substring($Position)}
            $SearchRoots = $SearchRootArray | select -Unique
 
            ##Active Directory query portion.
 
            #Getting domain list from Active Directory to verify and match SCCM client (NetBIOSName) domain property.
            $DomainList = Get-ADForest | select -ExpandProperty Domains
 
            #Iterate through the SCCM Discovered domains and Active Directory domains to get the Server Property for querying AD Computers.
            Foreach ($Root in $SearchRoots) {
                Foreach ($Domain in $DomainList) {
                    $DomainControllerList += Get-ADDomain -Identity $Domain | Where-Object {$_.DistinguishedName -eq $Root} | select -ExpandProperty PDCEmulator
                }
            }
 
            #Getting all Active Directory computers from all domains found.
            Foreach ($DomainController in $DomainControllerList) {
                $NetBIOSName = Get-ADDomain -Server $DomainController | select -ExpandProperty NetBIOSName
                $All_ADComputers += Get-ADComputer -Filter * -Server $DomainController | select Name, Enabled, @{Name = 'Domain'; Expression = {$NetBIOSName} }
            }
 
            #Creating a sub group that only contain disabled computer accounts in AD.
            $ADComputerList = $All_ADComputers | Where-Object {$_.Enabled -eq $false} | Select Name, Domain
 
            #Reformatting the array to eliminate Enabled field.
            $All_ADComputers = $All_ADComputers | Select Name, Domain
 
 
            ##SCCM Query Portion.
 
            #Setting location to SCCM PSDrive.
            Set-Location "$($CMSiteCode):"
 
            #Getting all SCCM Computer objects.
            $All_CMComputers = Get-CMDevice -CollectionName 'All Systems' | Where-Object {$_.Name -notlike "*Unknown Computer)"} | Select Name, Domain
 
            if ($CMCollection -eq 'All Systems') {
                    $CMComputerList = $All_CMComputers
                } else {
                    $CMComputerList = Get-CMDevice -CollectionName $CMCollection |  Where-Object {$_.Name -notlike "*Unknown Computer)"} | Select Name, Domain
            }
 
            #Using Compare-Object cmdlet to compare both arrays.
            $RemoveComputersFromSCCM += Compare-Object -ReferenceObject $All_ADComputers -DifferenceObject $All_CMComputers -IncludeEqual -Property Name, Domain | Where-Object {$_.SideIndicator -eq '=>'} | select Name, Domain, @{Name = 'AD_Status'; Expression = {'Deleted'}}
             
            if (($CMComputerList.count -eq 0) -or ($ADComputerList.count -eq 0)) {
                #Do nothing since there are no objects in one of the computer lists.
            } else {
                $RemoveComputersFromSCCM += Compare-Object -ReferenceObject $ADComputerList -DifferenceObject $CMComputerList -IncludeEqual -ExcludeDifferent -Property Name, Domain | select Name, Domain, @{Name = 'AD_Status'; Expression = {'Disabled'}}
            }
             
 
        } catch {
            Write-Output 'An Error Occured'
 
        } finally {
            if ($RemoveComputersFromSCCM) {
                Write-Output $RemoveComputersFromSCCM
            } else {
                Write-Output ""
                Write-Output 'There are no objects to delete from SCCM'
            }
             
 
            #Remove the '-Whatif' when you're ready to actually delete the objects from SCCM.
            if ($DeleteComputers) {
                $RemoveComputersFromSCCM | Foreach {Remove-CMDevice -Name $_.Name -Force -WhatIf}
            }
        }
    }
 
    END {
        Set-Location C:\
 
    }
 
}