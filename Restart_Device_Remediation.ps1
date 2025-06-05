# Ensure BurntToast module is installed
if (-not (Get-Module -ListAvailable -Name BurntToast)) {
    Install-Module -Name BurntToast -Force -Scope CurrentUser
    Import-Module BurntToast -Force
} else {
    Import-Module BurntToast -Force
}

$Last_reboot = Get-CimInstance Win32_OperatingSystem | Select-Object -ExpandProperty LastBootUpTime	

# Check if fast boot is enabled: if enabled uptime may be wrong
$Check_FastBoot = (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -ea silentlycontinue).HiberbootEnabled 

# If fast boot is not enabled
If(( $null -eq $Check_FastBoot ) -or ( 0 -eq $Check_FastBoot ))
	{
		$Boot_Event = Get-WinEvent -ProviderName 'Microsoft-Windows-Kernel-Boot' | Where-Object { $_.ID -eq 27 -and $_.message -like "*0x0*" }
		If($null -ne $Boot_Event)
			{
				$Last_boot = $Boot_Event[0].TimeCreated		
			}
	}
ElseIf($Check_FastBoot -eq 1) 	
	{
		$Boot_Event = Get-WinEvent -ProviderName 'Microsoft-Windows-Kernel-Boot' | Where-Object { $_.ID -eq 27 -and $_.message -like "*0x1*" }
		If($null -ne $Boot_Event)
			{
				$Last_boot = $Boot_Event[0].TimeCreated		
			}			
	}		
	
If($null -eq $Last_boot)
	{
		# If event log with ID 27 can not be found we checl last reboot time using WMI
		# It can occurs for instance if event log has been cleaned	
	}
Else
	{
		If($Last_reboot -ge $Last_boot)
			{
				$Uptime = $Last_reboot
			}
		Else
			{
				$Uptime = $Last_boot
			}	
	}


$Current_Date = get-date
$Diff_boot_time = NEW-TIMESPAN –Start $Last_reboot –End $Current_Date
$Boot_Uptime_Days = $Diff_boot_time.Days	

# Toast info
$Title = "Restart is needed as your computer has not been restarted for $Boot_Uptime_Days day(s)"
$Message = "To ensure the stability and proper functioning of your system, consider rebooting your device very soon."

New-BurntToastNotification -Text $Title, $Message
