$Baselines = Get-CimInstance -Namespace rootccmdcm -Class SMS_DesiredConfiguration
$Baselines | % { ([wmiclass]"\root\ccm\dcm:SMS_DesiredConfiguration").TriggerEvaluation($_.Name, $_.Version) }