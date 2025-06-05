# Ensure BurntToast module is installed
if (-not (Get-Module -ListAvailable -Name BurntToast)) {
    Install-Module -Name BurntToast -Force -Scope CurrentUser
    Import-Module BurntToast -Force
} else {
    Import-Module BurntToast -Force
}

# Threshold for reboot recommendation (set to 1 for testing)
$ThresholdDays = 1

# Calculate uptime
$LastBoot = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
$Days = (New-TimeSpan -Start $LastBoot -End (Get-Date)).Days

# Toast info
$Title = "Your computer needs to be restarted as it has not been restarted for $Days day(s)."
$Message = "To ensure the stability and proper functioning of your system, consider rebooting your device very soon."

# Show toast only if uptime exceeds threshold
if ($Days -ge $ThresholdDays) {
    if (Test-Path $HeroImage) {
		# HeroImage + Button (no SnoozeAndDismiss)
		New-BurntToastNotification -Text $Title, $Message
	}
}