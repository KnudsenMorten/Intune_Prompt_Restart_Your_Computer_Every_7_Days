﻿##################################################################################################
# Variables
$Reboot_Delay = 7
##################################################################################################

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
$Hour = $Diff_boot_time.Hours
$Minutes = $Diff_boot_time.Minutes
$Reboot_Time = "$Boot_Uptime_Days day(s)" + " $Hour hour(s)" + " $minutes minute(s)"						
If($Boot_Uptime_Days -ge $Reboot_Delay)
	{
		write-output "RESTART NEEDED !"
		write-output "Last reboot/shutdown: $Reboot_Time"			
		EXIT 1		
	}
Else
	{
		write-output "NO RESTART NEEDED"
		write-output "Last reboot/shutdown: $Reboot_Time"
		EXIT 0
	}		