# Log actions in the %temp% directory
$Timestamp = Get-Date -Format "yyyy-MM-dd_THHmmss"
$LogFile = "$env:TEMP\DellUninst_$Timestamp.log"

# Search registry for uninstall string(s)
$ProgramList = @( "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*", "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" )
$Programs = Get-ItemProperty $ProgramList -EA 0
$App = ($Programs | Where-Object { $_.DisplayName -like "*SupportAssist*" -and $_.UninstallString -like "*msiexec*" }).PSChildName

# Kill task if it's running
Get-Process | Where-Object { $_.ProcessName -like "SupportAssist*" } | Stop-Process -Force

# Loop through and uninstall any matches
foreach ($a in $App) {
	$Params = @(
		"/qn"
		"/norestart"
		"/X"
		"$a"
		"/L*V ""$LogFile"""
	)
	Start-Process "msiexec.exe" -ArgumentList $Params -Wait -NoNewWindow
}
