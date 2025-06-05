# Ensure BurntToast module is installed
if (-not (Get-Module -ListAvailable -Name BurntToast)) {
    Install-Module -Name BurntToast -Force -Scope CurrentUser
    Import-Module BurntToast -Force
} else {
    Import-Module BurntToast -Force
}

# Toast info
$Title = "Your computer needs to be restarted as it has not been restarted for $Days day(s)."
$Message = "To ensure the stability and proper functioning of your system, consider rebooting your device very soon."

# Show toast only if uptime exceeds threshold
New-BurntToastNotification -Text $Title, $Message
